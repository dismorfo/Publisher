#!/usr/bin/perl

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

# add app common sub routines
do 'cgi/common.pl';

# request type
my $pjax = param("pjax");

# add specific page/content sub routines
if (defined($pjax) ) {
  do 'cgi/pages/published.pjax.pl';
}

else {
  do 'cgi/pages/published.page.pl';
}

my @route = getRoute();

my $identifier = ($#route > 2) ? @route[$#route] : param("identifier");

# In order to render a HTML is require to pass a data source hash with: pid, title and content
my ($datasource) = {	
  # page id
  'pid' => 'page-published',
  
  'identifier' => $identifier,

  # title of the page
  'title' => 'Review published finding aids',

  # scripts
  'scripts' => ['ui.menu.js', 'ui.published.js'],

  # scripts size
  'scripts_size' => 1,

  # main content of the page
  'content' => publishedFiles($identifier)
 
};
    
# print HTML page
outputHTML($datasource);