#!/usr/bin/perl

use Cwd;
use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use FileHandle;

# add app common sub routines
require 'cgi/common.pl';

# cast loaded settings and configuration into a hash
my %confHash = createHashConf('conf/eadpublisher.conf');

sub publish {

  my $status;
  
  my $deploy = '';

  my $eadId = param("eadId");
  
  my $eadRepo = param("eadRepo");

  my $repo = $eadRepo;
  
  my $faid = $eadId;

  # the files to be fed to SOLR
  my $solr1 = "$confHash{'CONTENT_STAGING_PATH'}/solr1/$repo/$faid.solr.xml";
  my $solr2 = "$confHash{'CONTENT_STAGING_PATH'}/solr2/$repo/$faid.solr.xml";
    
  # the ead file in the preview area; the html directory in the preview area
  my $ead = "$confHash{'CONTENT_STAGING_PATH'}/ead/$repo/$faid.xml";
  my $html = "$confHash{'CONTENT_STAGING_PATH'}/html/$repo/$faid";
    
  # the target path and URI for the html content
  my $published = "$confHash{'CONTENT_PATH'}/html/$repo/$faid";
  my $publishedURL = "$confHash{'CONTENT_URI'}/html/$repo/$faid\/";
    
  print header;
  
  # Ensure that target repository directories exist
  my $eadDIR = "$confHash{'CONTENT_PATH'}/ead/$repo";
  my $htmlDIR = "$confHash{'CONTENT_PATH'}/html/$repo";    
  
  if (! -d $eadDIR){
    mkdir($eadDIR);
    chmod(0777, $eadDIR);
  }

  if (! -d $htmlDIR) {
    mkdir($htmlDIR);
    chmod(0777, $htmlDIR);
  }

  # Ensure that Solr records exist
  if (! (-e $solr1) && (-e $solr2) ){
    print "<p>Error: Search files could not be found: can't publish this finding aid.</p>";
    exit();
  }
    
  # Ensure that the source EAD and HTML content exist
  if (! (-e $ead) && (-d $html) ){
    print '<p>Error: Source ead and / or html files not found: can\'t publish this finding aid. </p>';
    exit();
  }
    
  my $deployEad = $confHash{'APP_PATH'} . "/bin/deploy-ead.bash";
    if (-x $deployEad) {
	  my @args = ($deployEad, "$repo/$faid");
	  $deploy = system(@args);
  }
  else{
    print "Error: The following file is not executable: $deployEad";
    exit();
  }

  if (-e $published && $deploy == 0){ 
    print "<a href=\"$publishedURL\">$publishedURL</a> has been successfully published";
    my $eadPublished = "$confHash{'CONTENT_PATH'}/ead/$repo/$faid".".xml";
  }
  else {
    print '<p>There was a problem - please contact the administrator.</p>';
  }

}

publish();