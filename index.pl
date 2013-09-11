#!/usr/bin/perl

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use feature qw(switch);

my $route = $ENV{'SCRIPT_URL'};

given($route) {

  when('/publisher/publish') {
    require 'cgi/eadManager.publish.pl'; 
  }

  when('/publisher/published') {
  	require 'cgi/eadManager.published.pl'; 
  }

  default {
    # route /
    require 'cgi/eadManager.index.pl';
  }

}
  
# we are done here
exit();