#!/usr/bin/perl

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

# add app common sub routines
require 'cgi/common.pl';

require 'cgi/pages/index.page.pl';

# in order to render a HTML is require to pass a data source 
# hash with: pid, title and content


# initializing hash to render as HTML

my ($datasource) = {
  
  # page id
  'pid' => 'page-index',

  # title of the page
  'title' => 'Home',

  # scripts
  'scripts' => ['ui.menu.js'],
    
  # scripts size
  'scripts_size' => 1,
    
  # main content of the page
  'content' => getBody()
};
    
# print HTML page
outputHTML($datasource);
    
# print HTML page
outputHTML($datasource);