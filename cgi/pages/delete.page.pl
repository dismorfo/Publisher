#!/usr/bin/perl

use Cwd;
use strict;
use File::Copy;

my $dir = cwd();

# load settings and configuration options
do $dir . 'cgi/inc/readConf.pl';

# cast loaded settings and configuration into a hash
my %confHash = createHashConf('conf/eadpublisher.conf');

sub delete_ead {
	
  my (%route) = @_;

  my $output = '';

  # grabbing file
  my $eadFile = param("eadfile");

  # grabbing file dir
  my $eadDir =  param("eaddir");
  
  my $dir =  @_[3];
  
  my $eadid =  @_[4];
  
  # Transform and write the SOLR input files
  my $cmd = $confHash{'APP_PATH'} . '/bin/delete-preview-ead.bash ' . $dir . '/' . $eadid;
 
  my $transform = `$cmd`;
  
  return $transform;

}