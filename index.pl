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
  	do 'cgi/eadManager.help.pl';
  }

  when(/^\/publisher\/publish\/([a-z])+/) {
    do 'cgi/eadManager.publish.pl';
  }

  when(/^\/publisher\/published\/([a-z])+/) {
    do 'cgi/eadManager.published.pl';
  }

  when(/^\/publisher\/upload\/([a-z])+/ && ($ENV{'REQUEST_METHOD'} eq 'POST') ) {
    do 'cgi/eadManager.upload.pl';
  }

  when(/^\/publisher\/publicate\/[a-z]+\/\w+/ && ($ENV{'REQUEST_METHOD'} eq 'POST') ) {
  	do 'cgi/publish.pl';
  }

  when(/^\/publisher\/delete\/[a-z]+\/\w+/ && ($ENV{'REQUEST_METHOD'} eq 'POST') ) {  	
    do 'cgi/eadManager.delete.pl';
  }  

  # this one should default to 404
  default {
    do 'cgi/eadManager.index.pl';
  }

}

# we are done here
exit();