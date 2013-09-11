#!/usr/bin/perl

use strict;

# load settings and configuration options
do 'inc/readConf.pl';

# cast loaded settings and configuration into a hash
my %confHash = createHashConf("../conf/eadpublisher.conf");

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
  
  my $previewDir = "$confHash{'CONTENT_STAGING_PATH'}/html";
  
  # my @pendingEAD = `ls $previewDir/$dir/`;
  
  my @pendingEAD = `ls $confHash{'CONTENT_STAGING_PATH'}/ead/$dir`;
  
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
    <h3 class="title">$heading</h3>
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