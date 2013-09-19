#!/usr/bin/perl

use Cwd;
use strict;

my $dir = cwd();

# load settings and configuration options
# require 'cgi/inc/readConf.pl';

# cast loaded settings and configuration into a hash
my %confHash = createHashConf('conf/eadpublisher.conf');

# small routine to read in a conf file and parse it into a hash
# used in two cgi programs:eadManager and ppublish
# initial creation: edatta 8/21/07

sub createHashConf {
  # text file to be specified
  my $text = shift;

  # initializing hash
  my %confHash = ();

  # opening file
  open(CONF, $text) || die "can't open file " . $text;

  # reading in file
  while (my $line = <CONF>){
    # removing line feeds
    chop($line);

    # grabbing only key value pairs:VAR=p=ath
    if ($line =~ /^[A-Z0-9a-z]/) {
      # splitting var and path
      my($var,$path) = split(/=/, $line);

      # assigning to has
      $confHash{$var}=$path;
    }
  }
  return %confHash;
}

sub listOfCollections {
  # initializing hash to store collections
  my %collections = ();
  $collections{'archives'} = 'University Archives';
  $collections{'fales'} = 'Fales';
  $collections{'tamwag'} = 'Tamiment-Wagner';
  $collections{'nyhs'} = 'NYHS';
  $collections{'rism'} = 'Research Institute for the Study of Man';
  $collections{'bhs'} = 'Brooklyn Historical Society';
  $collections{'poly'} = 'Poly Archives';
  return %collections;
  
}

sub publisher_start_html {
  return '<!doctype html><html>';
}

sub publisher_end_html {
  return '</html>';
}

sub publisher_head {

  my ($title) = @_;
  
  my $head = qq#
      <head>
        <title>EAD publisher | $title</title>
        <meta charset="utf-8">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="http://yui.yahooapis.com/pure/0.3.0/pure-min.css">
        <link href='http://fonts.googleapis.com/css?family=Droid+Sans' rel='stylesheet' type='text/css'>
        <link rel="stylesheet" href="$confHash{'PUBLISHER_URI'}/assets/css/base.css">
        
      </head>
  #; 
  return $head;  
}

sub getRoute {
  # the requested path
  my $request = $ENV{'SCRIPT_URL'};

  # if requested path has a trailing backslash remove it
  my $route = ( (substr $request, -1, 1) eq '/') ? substr($request, 0, -1) : $request;
  
  my @arg = split(/\//, $route);
  
  return @arg;
}

sub publisher_navigation {
	
  # collections look up
  my %collections = listOfCollections();
  
  my $archives_upload = "";
  
  my $archives_preview = "";
  
  my $archives_review = "";
  
  for (keys %collections) {
    $archives_upload .= '<li><a href="' . $confHash{"PUBLISHER_URI"} . '/upload/' . $_ . '">' . $collections{$_} . '</a></li>';
    $archives_preview .= '<li><a href="' . $confHash{"PUBLISHER_URI"} . '/publish/' . $_ . '">' . $collections{$_} . '</a></li>';
    $archives_review .= '<li><a href="' . $confHash{'PUBLISHER_URI'} . '/cgi/eadManager.published.pl?identifier=' . $_ . '">' . $collections{$_} . '</a></li>';
  }
	
  my $navigation = qq#
    <div id="horizontal-menu">
      <ul id="std-menu-items">
        <li><a href="$confHash{'APP_URI'}/">Home</a></li>
        <li>
          Upload, preview or publish finding aids
          <ul>
            <li class="pure-menu-heading">Select archive</li>
            <li class="pure-menu-separator"></li>
            $archives_preview
          </ul>
        </li>
        <li>
          Review published finding aids
          <ul>
            <li class="pure-menu-heading">Select archive</li>
            <li class="pure-menu-separator"></li>
            $archives_review
          </ul>
        </li>        
        <!--
        <li>
          <a href="$confHash{'PUBLISHER_URI'}/cgi/upload_csv.html">Process accessions report</a>
        </li>
        -->
    </ul>
  </div>
  #;
  
  return $navigation;  
}

sub publisher_scripts {
  
  my ($datasource) = @_;
  
  my $output = '';
  
  $output .= '<script src="http://yui.yahooapis.com/3.12.0/build/yui/yui-min.js"></script>';
  
  for ( my $i = 0; $i <= $datasource->{"scripts_size"} ; $i++)  { 
    $output .= '<script src="'. $confHash{'PUBLISHER_URI'} . '/assets/js/' . $datasource->{"scripts"}[$i] .'"></script>';    
  }  

  return $output;
}

sub publisher_content {

  my ($content) = @_;

  my $output = qq#
    <div class="main">
      <div class="body">
        <div class="content">$content</div>
      </div>
    </div>
  #;
  
  return $output;
    
}

sub publisher_body {

  my ($datasource) = @_;
  
  my $output = "";
  
  # request type
  my $pjax = isPJAX();
  
  # content
  my $content = publisher_content($datasource->{'content'});
  
  if (defined($pjax) ) {
  	
    $output .= $content;

  }  
  else {
  	
    # navigation
    my $navigation =  publisher_navigation();
    
    # scripts
    my $scripts = publisher_scripts($datasource);
  	
    $output .= '<body id="' . $datasource->{'pid'} . '" class="yui3-skin-sam">' . $navigation . $content . $scripts . '</body>';
  }
  
  return $output;
  
}

sub isPJAX() {
  my $isPJAX = param("pjax");
  return $isPJAX;
}

sub outputHTML {

  my ($datasource) = @_;
  
  # request type
  my $pjax = isPJAX();

  print header;
  
  # add specific page/content sub routines
  if (defined($pjax) ) {
    print publisher_body($datasource);
  }
  else {
    print publisher_start_html();
    print publisher_head($datasource->{"title"});  
    print publisher_body($datasource);
    print publisher_end_html();   
  }  
}

1;