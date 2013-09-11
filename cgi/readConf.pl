#!/usr/bin/perl

use strict;

# small routine to read in a conf file and parse it into a hash
# used in two cgi programs:eadManager and ppublish
# initial creation: edatta 8/21/07

sub createHashConf {
  # text file to be specified
  my $text = shift;

  # initializing hash
  my %confHash = ();

  # opening file
  open(CONF, $text) || die "can't open file";

  # reading in file
  while (my $line = <CONF>){
    # removing line feeds
    chop($line);

    # grabbing only key value pairs:VAR=p=ath
    if ($line =~ /^[A-Z0-9a-z]/) {
      # splitting var and path
      my($var,$path) = split(/=/, $line);

      # assigning to has
      $confHash{$var}=$path;
    }
  }
  return %confHash;
}

1;