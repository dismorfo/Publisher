#!/usr/bin/perl

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

# my $isPjax = $q->header('PJAX');

# add app common sub routines
require 'inc/common.pl';

# request type
my $pjax = param("pjax");

# add specific page/content sub routines
if (defined($pjax) ) {
  require 'pages/publish.pjax.pl';
}

else {
  require 'pages/published.page.pl';
}

#parameter in the form of {repository}_{finding aid id}
my $identifier = param("identifier");

# In order to render a HTML is require to pass a data source hash with: pid, title and content

# initializing hash to render as HTML
my %datasource = ();

   # page id
   $datasource{'pid'} = 'page-published';

   # requested identifier
   $datasource{'identifier'} = $identifier;   

   # title of the page
   $datasource{'title'} = 'Review published finding aids';
   
   # main content of the page
   $datasource{'content'} = publishedFiles($identifier);

# Print HTML page
outputHTML(%datasource);

# we are done here
exit();