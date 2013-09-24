#!/usr/bin/perl

use Cwd;
use strict;

my $dir = cwd();

# load settings and configuration options
do $dir . 'cgi/inc/readConf.pl';

# cast loaded settings and configuration into a hash
my %confHash = createHashConf("conf/eadpublisher.conf");

sub publicate_archive {
	
  my $status;

  my $deploy = '';

  my $repo = param("eadRepo");
  
  my $faid = param("eadId");

  # the files to be fed to SOLR
  my $solr1 = "$confHash{'CONTENT_STAGING_PATH'}/solr1/$repo/$faid.solr.xml";
  my $solr2 = "$confHash{'CONTENT_STAGING_PATH'}/solr2/$repo/$faid.solr.xml";

  # the ead file in the preview area; the html directory in the preview area
  my $ead = "$confHash{'CONTENT_STAGING_PATH'}/ead/$repo/$faid.xml";
  my $html = "$confHash{'CONTENT_STAGING_PATH'}/html/$repo/$faid";

  # the target path and URI for the html content
  my $published = "$confHash{'CONTENT_PATH'}/html/$repo/$faid";
  my $publishedURL = "$confHash{'CONTENT_URI'}/html/$repo/$faid\/";
    
  # Ensure that target repository directories exist
  my $eadDIR = "$confHash{'CONTENT_PATH'}/ead/$repo";
  my $htmlDIR = "$confHash{'CONTENT_PATH'}/html/$repo";
  
  if (! -d $eadDIR) {
    mkdir($eadDIR);
    chmod(0777, $eadDIR);
  }

  if (! -d $htmlDIR) {
    mkdir($htmlDIR);
    chmod(0777, $htmlDIR);
  }

  # Ensure that Solr records exist
  if (! (-e $solr1) && (-e $solr2) ) {
    return "<p>Error: Search files could not be found: can't publish this finding aid.</p>";
  }
    
  # Ensure that the source EAD and HTML content exist
  if (! (-e $ead) && (-d $html) ){
    return '<p>Error: Source ead and / or html files not found: can\'t publish this finding aid. </p>';
  }

  my $deployEad = $dir . '/bin/deploy-ead.bash';
  
  if (-x $deployEad) {
	my @args = ($deployEad, $repo . "/" . $faid);
    $deploy = system(@args);
  }

  else {
    return "<p>Error: The following file is not executable: " . $deployEad ."</p>";
  }
  
  if ($deploy == 0) { 
    return '<p><a href="' . $publishedURL .'">' . $publishedURL . '</a> has been successfully published</p>';
  }

  else {
    return '<p>There was a problem - please contact the administrator.</p>';
  }
  
  return $deploy;
}