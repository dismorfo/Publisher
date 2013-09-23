#!/usr/bin/perl  

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

# add app common sub routines
require 'cgi/common.pl';

# add specific page/content sub routines
require 'cgi/pages/upload.page.pl';

# In order to render a HTML is require to pass a data source hash with: pid, title and content
my ($datasource) = {
  # page id
  'pid' => 'page-upload',
  
  # title of the page
  'title' => 'Upload EAD',

  # main content of the page
  'content' =>  processUpload(),
 
};

# print HTML page
outputHTML($datasource);