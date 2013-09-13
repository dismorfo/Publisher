#!/usr/bin/perl  

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

# add app common sub routines
require 'cgi/common.pl';

# add specific page/content sub routines
require 'cgi/pages/upload.page.pl';

my @route = getRoute();

my $identifier = ($#route > 2) ? @route[$#route] : param("identifier");

# In order to render a HTML is require to pass a data source hash with: pid, title and content
my ($datasource) = {
  # page id
  'pid' => 'page-upload',
  
  'identifier' => $identifier,

  # title of the page
  'title' => 'Upload EAD',

  # scripts
  'scripts' => ['ui.menu.js', 'ui.upload.js'],
    
  # scripts size
  'scripts_size' => 1,
  
 # main content of the page
 'content' =>  ($ENV{'REQUEST_METHOD'} eq 'POST') ? processUpload() : uploadFile($identifier),
 
  'route' => @route,

};

# print HTML page
outputHTML($datasource);