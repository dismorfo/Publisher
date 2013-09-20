#!/usr/bin/perl

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

# add app common sub routines
require 'cgi/common.pl';

# request type
my $pjax = param("pjax");

# add specific page/content sub routines
if (defined($pjax) ) {
  require 'cgi/pages/publish.pjax.pl';
}

else {
  require 'cgi/pages/publish.page.pl';
}

my @route = getRoute();

my $identifier = ($#route > 2) ? @route[$#route] : param("identifier");

# In order to render a HTML is require to pass a data source hash with: pid, title and content
my ($datasource) = {	
  # page id
  'pid' => 'page-publish',
  
  'identifier' => $identifier,

  # title of the page
  'title' => 'Upload, Preview and publish pending finding aids',

  # scripts
  'scripts' => ['ui.menu.js', 'ui.publish.js'],
    
  # scripts size
 'scripts_size' => 1,
    
 # main content of the page
 'content' => lsFiles($identifier)
};
    
# print HTML page
outputHTML($datasource);