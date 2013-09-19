#!/usr/bin/perl

use Cwd;
use strict;

my $dir = cwd();

# load settings and configuration options
do $dir . 'cgi/inc/readConf.pl';

# cast loaded settings and configuration into a hash
my %confHash = createHashConf("conf/eadpublisher.conf");

sub lsFiles {

  my ($identifier) = @_;

  # collections look up
  my %collections = listOfCollections();

  # html to output the tab
  my $collections_tab = '';

  # html to output the collection items tables
  my $collections_output = '';

  # iterate collections and build the html to be render
  for (keys %collections) {
    $collections_tab .= '<li class="archive-' . $_ . ($_ eq $identifier ? ' selected' : '') . '"><a href="#' . $_ . '" class="tab archive-' . $_ . '" data-id="' . $_ . '" data-upload="' . $confHash{'PUBLISHER_URI'} . '/upload/' . $_ .'" data-name="' . $collections{$_} . '" data-uri="' . $confHash{'PUBLISHER_URI'} . '/publish/' . $_ . '">' . $collections{$_} . '</a></li>';
    if ( defined($identifier) && ($_ eq $identifier) ) {
      $collections_output .= '<div id="' . $_ . '">' . outputFiles($_, $collections{$_}) . '</div>';
    }
    else {
      $collections_output .= '<div id="' . $_ . '"></div>';
    }
  }

  my $body = qq#
    <div class="container msg"></div>
    <div class="overlay">
      <div id="panelContent">
        <div class="yui3-widget-bd"></div>
      </div>
      <div id="nestedPanel"></div>
    </div>
    <h3 class="title">Upload <span class="archive">$collections{$identifier}</span> archive</h3>
    <div class="cu">
      <div id="uploaderContainer">
        <div id="selectFilesButtonContainer"></div>
        <div id="uploadFilesButtonContainer">
          <button type="button" id="uploadFilesButton" class="yui3-button" style="width:250px; height:35px;">Upload Files</button>
        </div>
        <div id="overallProgress"></div>
      </div>
      <div id="filelist">
        <table id="filenames" class="tab-table pure-table pure-table-bordered pure-table-striped">
          <thead>
            <tr><th>File name</th>
            <th>Percent uploaded</th></tr>
            <tr id="nofiles">
              <td colspan="2">No files have been selected.</td>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>
    </div>
    <form name="publish" class="archive-table pure-form pure-form-stacked">
      <fieldset>
        <legend>Preview / publish pending <span class="archive">$collections{$identifier}</span> archive</legend>
      </fieldset>
      <div id="collections">
        <ul>$collections_tab</ul>
        <div>$collections_output</div>
      </div>
    </form>
  #;
  
  return $body;
}

sub outputFiles {

  my ($dir, $heading) = @_;
  my $previewDir = "$confHash{'CONTENT_STAGING_PATH'}/html";
  my @pendingEAD = `ls $previewDir/$dir/`;
  my $tbody = "";
  
  foreach (@pendingEAD) {
    unless ($_ =~ /_content\.html/ || $_ =~ /_toc\.html/) {
      chop($_);
      $_ =~ s/.*\/(.*).html/$1/;
      my $id = "$dir\_$_";
      $tbody .= '<tr>';
      $tbody .= '<td>' . $_ . '</td>';
      $tbody .= '<td><a href="' . $confHash{'CONTENT_STAGING_URI'} . '/ead/' . $dir . '/' . $_ . '.xml" target="_blank">EAD</a></td>';
      $tbody .= '<td><a href="' . $confHash{'CONTENT_STAGING_URI'} . '/html/' . $dir . '/' . $_ . '" target="_blank">HTML</a></td>';
      $tbody .= '<td><a href="' . $confHash{'CONTENT_STAGING_URI'} . '/solr1/' . $dir . '/' . $_ . '.solr.xml" target="_blank">Inner</a></td>';
      $tbody .= '<td><a href="' . $confHash{'CONTENT_STAGING_URI'} . '/solr2/' . $dir . '/' . $_ . '.solr.xml" target="_blank">Outer</a></td>';
      $tbody .= '<td><a href="#' . $id . '" data-action="publish" data-eadid="' . $id . '" data-repo="'. $dir . '" class="publish">Publish</a></td>';
      $tbody .= '<td><a href="' . $confHash{'PUBLISHER_URI'} . '/delete/' . $dir . '/' . $_ . '" data-action="delete" data-eadid="' . $id . '" data-repo="'. $dir . '" class="remove">Remove</a></td>';
      
      #
      
      $tbody .= '</tr>';
    }
  }  

  my $body = qq#
    <table class='tab-table pure-table pure-table-bordered pure-table-striped'>
      <thead>
        <tr>
          <th>Identifier</th>
          <th colspan="2" class="preview">Preview</th>
          <th colspan="2" class="solr">Solr</th>
          <th colspan="2" class="actions">Actions</th>
        </tr>
      </thead>
      <tbody>$tbody</tbody>
    </table>
  #;

  return $body;
}