#!/usr/bin/perl

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

# add app common sub routines
require 'cgi/common.pl';

# add specific page/content sub routines
require 'cgi/pages/publicate.page.pl';

my ($datasource) = {

  # page id
  'pid' => 'page-publicate',

  # title of the page
  'title' => 'Publicate pending finding aids',

  # main content of the page
  'content' => publicate_archive()

};
    
# print HTML page
outputHTML($datasource);