#!/usr/bin/perl

use strict;

sub getBody {
  my $body = qq#
    <h2>Error</h2>
    <p>Not found</p>
  #;  
  return $body;
}