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
    
    $collections_tab .= '<li class="archive-' . $_ . '"><a href="#' . $_ . '" class="tab archive-' . $_ . '" data-id="' . $_ . '" data-uri="' . $confHash{'PUBLISHER_URI'} . '/cgi/eadManager.publish.pl?identifier=' . $_ . '">' . $collections{$_} . '</a></li>';
    
    if ( defined($identifier) && ($_ eq $identifier) ) {
      $collections_output .= '<div id="' . $_ . '">' . outputFiles($_, $collections{$_}) . '</div>';
    }
    else {
      $collections_output .= '<div id="' . $_ . '"></div>';
    }
    
  }

  my $body = qq#
      <form name="publish" class="pure-form pure-form-stacked">
        <fieldset>
          <legend>Preview / publish pending finding aids</legend>
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
      $tbody .= "<tr>";
      $tbody .= "<td>$_</td>";
      $tbody .= "<td><a href=\"$confHash{'CONTENT_STAGING_URI'}/ead/$dir/$_.xml\">EAD</a></td>";
      $tbody .= "<td><a href=\"$confHash{'CONTENT_STAGING_URI'}/ead/$dir/$_.xml\">HTML</a></td>";      
      $tbody .= "<td><a href=\"#$id\" data-eadid=\"$id\" data-action=\"publish\">Publish</a></td>";
      $tbody .= "<td><a href=\"#$id\" data-eadid=\"$id\" data-action=\"remove\">Remove</a></td>";
      $tbody .= "</tr>";
    }
  }  

  my $body = qq#
    <h3 class="title hidden">$heading</h3>
    <table class='tab-table pure-table pure-table-bordered pure-table-striped'>
      <thead>
        <tr>
          <th>Identifier</th>
          <th colspan="2" class="preview">Preview</th>
          <th colspan="2" class="actions">Actions</th>
        </tr>
      </thead>
      <tbody>$tbody</tbody>
    </table>
  #;

  return $body;
}