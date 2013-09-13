#!/usr/bin/perl

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use feature qw(switch);

# the requested path
my $request = $ENV{'SCRIPT_URL'};

# if requested path has a trailing backslash remove it
my $route = ( (substr $request, -1, 1) eq '/') ? substr($request, 0, -1) : $request;

# list of routes
given($route) {

  # home
  when('/publisher') {
  	do 'cgi/eadManager.index.pl';
  }
  
  # help
  when('/publisher/help') {
  	do 'cgi/eadManager.index.pl';
  }

  when('/publisher/upload') {
  	do 'cgi/eadManager.upload.pl';
  }
    
  when(/^\/publisher\/upload\/([a-z])+/) {
    do 'cgi/eadManager.upload.pl';
  }

  when('/publisher/publish') {
    do 'cgi/eadManager.publish.pl'; 
  }
  
  when(/^\/publisher\/publish\/([a-z])+/) {
    do 'cgi/eadManager.publish.pl';
  }

  when('/publisher/published') {
  	do 'cgi/eadManager.published.pl';
  }
  
  when(/^\/publisher\/published\/([a-z])+/) {
    do 'cgi/eadManager.published.pl';
  }  

  # this one should default to 404
  default {
    do 'cgi/eadManager.index.pl';
  }

}

# we are done here
exit();