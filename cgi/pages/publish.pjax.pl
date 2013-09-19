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
  if ( defined($identifier) && exists($collections{$identifier})) {
    $collections_output .= '<div id="' . $identifier . '">' . outputFiles($identifier, $collections{$identifier}) . '</div>';
  }
  else {
    $collections_output .= '<div id="unknown"><h2>Unable to find collection</h2></div>';
  }
  
  return $collections_output;
}

sub outputFiles {

  my ($dir, $heading) = @_;
  
  my $previewDir = $confHash{'CONTENT_STAGING_PATH'} . '/html';
  
  my @pendingEAD = `ls $previewDir/$dir/`;
  
  my $tbody = '';
  
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
      $tbody .= '<td><a href="#' . $id . '" data-action="remove" data-eadid="' . $id . '" data-repo="'. $dir . '" class="remove">Remove</a></td>';
      $tbody .= '</tr>';
    }
  }

  my $body = qq#
    <h3 class="title">$heading</h3>
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