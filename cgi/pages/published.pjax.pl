#!/usr/bin/perl

use Cwd;
use strict;

my $dir = cwd();

# load settings and configuration options
do $dir . 'cgi/inc/readConf.pl';

# cast loaded settings and configuration into a hash
my %confHash = createHashConf("conf/eadpublisher.conf");

sub publishedFiles {

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
      $collections_output .= '<div id="' . $_ . '">' . showPublished($_, $collections{$_}) . '</div>';
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
    <form name="published" class="archive-table pure-form pure-form-stacked">
      <fieldset>
        <legend>Review published <span class="archive">$collections{$identifier}</span> finding aids</legend>
      </fieldset>
      <div id="collections">
        <ul>$collections_tab</ul>
        <div>$collections_output</div>
      </div>
    </form>
  #;
  return $body;
}

sub showPublished {
  
  my ($dir, $heading) = @_;
  
  my $previewDir = $confHash{'CONTENT_PATH'} . '/html';
  
  my @publishedEAD = `ls $previewDir/$dir/`;
  
  my $tbody = '';
  
  foreach (@publishedEAD) {
    unless ($_ =~ /_content\.html/ || $_ =~ /_toc\.html/) {
      chop($_);
      $_ =~ s/.*\/(.*).html/$1/;
      my $id = "$dir\_$_";
      $tbody .= '<tr>';
      $tbody .= '<td>' . $_ . '</td>';
      $tbody .= '<td><a target="_blank" href="' . $confHash{'CONTENT_URI'} . '/ead/' . $dir . '/' . $_ . '.xml">EAD</a></td>';
      $tbody .= '<td><a target="_blank" href="' . $confHash{'CONTENT_URI'} . '/html/' . $dir . '/' . $_ . '">HTML</a></td>';
      $tbody .= '<td><a target="_blank" href="' . $confHash{'SOLR1_URI'} . '/select/?q=collection.id:' . $dir . '_' . $_ . '&wt=xml">Inner</a></td>';
      $tbody .= '<td><a target="_blank" href="' . $confHash{'SOLR2_URI'} . '/select/?q=id:' . $dir . '_' . $_ . '&wt=xml">Outer</a></td>';
      
      $tbody .= '</tr>';
    }
  }
  
  my $body = qq#
    <h3 class="title">$heading</h3>
    <table class="tab-table pure-table pure-table-bordered pure-table-striped">
      <thead>
        <tr>
          <th>Identifier</th>
          <th colspan="4" class="preview">Review published content</th>
        </tr>
      </thead>
      <tbody>$tbody</tbody>
    </table>
  #;

  return $body;
  
}