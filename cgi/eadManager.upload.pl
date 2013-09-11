#!/usr/bin/perl  

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use File::Basename;

$CGI::POST_MAX = 1024 * 5000;

# add app common sub routines
require 'inc/common.pl';

# add specific page/content sub routines
require 'pages/upload.page.pl';

#parameter in the form of {repository}_{finding aid id}
my $identifier = param("identifier");

# In order to render a HTML is require to pass a data source hash with: pid, title and content

  # JavaScripts
  # my @scripts = ('ui.menu.js', 'ui.upload.js');

  # initializing hash to render as HTML
  my %datasource = ( 'js' => (['ui.menu.js', 'ui.upload.js']));

  my $output = '';
  
  my %m = $datasource{'js'};

  foreach (%m) {
    $output .= $m{$_};
  }

  # page id
  $datasource{'pid'} = 'page-publish';
   
  # requested identifier
  $datasource{'identifier'} = $identifier;

  # title of the page
  $datasource{'title'} = 'Upload EAD';
   
  # main content of the page
  if ($ENV{'REQUEST_METHOD'} eq "POST") {
   	$datasource{'content'} = processUpload();
  }
  else {
    $datasource{'content'} = uploadFile(%datasource);
  }
   

# print HTML page
outputHTML(%datasource);

print $output;

# we are done here
exit();