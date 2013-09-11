#!/usr/bin/perl

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

# add app common sub routines
require 'cgi/common.pl';

# request type
my $pjax = param("pjax");

my $q = CGI->new;

# add specific page/content sub routines
if (defined($pjax) ) {
  require 'cgi/pages/publish.pjax.pl';
}

else {
  require 'cgi/pages/publish.page.pl';
}

#parameter in the form of {repository}_{finding aid id}
my $identifier = param("identifier");

# In order to render a HTML is require to pass a data source hash with: pid, title and content
my ($datasource) = {	
  # page id
  'pid' => 'page-publish',
  
  'identifier' => $identifier,

  # title of the page
  'title' => 'Preview / publish pending finding aids',

  # scripts
  'scripts' => ['ui.menu.js', 'ui.publish.js'],
    
  # scripts size
 'scripts_size' => 2,
    
 # main content of the page
 'content' => lsFiles($identifier)
};
    
# print HTML page
outputHTML($datasource);