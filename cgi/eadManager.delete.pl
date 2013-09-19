#!/usr/bin/perl  

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

# add app common sub routines
require 'cgi/common.pl';

# add specific page/content sub routines
require 'cgi/pages/delete.page.pl';

my @route = getRoute();

my $identifier = ($#route > 2) ? @route[$#route] : param("identifier");

# In order to render a HTML is require to pass a data source hash with: pid, title and content
my ($datasource) = {
  
  # page id
  'pid' => 'delete-upload',
  
  'identifier' => $identifier,

  # title of the page
  'title' => 'Delete EAD',

  # main content of the page
  'content' =>  delete_ead(@route),
 
  'route' => @route,

};

# print HTML page
outputHTML($datasource);