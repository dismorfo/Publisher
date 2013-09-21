#!/usr/bin/perl -w

use strict;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;
use FileHandle;

do 'readConf.pl';
do 'accessReport.pl';

my %confHash = createHashConf("../conf/eadpublisher.conf");
my $safe_filename_characters = "a-zA-Z0-9_.-";
my $query = new CGI;
my $collection = $query->param("collection");
if ( $collection eq "default" )
{
 print $query->header();
 print "please select a collection.";
 exit;
}

my $filename = $query->param("csv_file");
my $reportFile = "$confHash{'CONTENT_PATH'}/report/$collection"."_report.html";
my $reportFileURL = "$confHash{'CONTENT_URI'}/report/$collection"."_report.html";

if ( !$filename )
{
 print $query->header();
 print "There was a problem uploading your file.";
 exit;
}

my ( $name, $path, $extension ) = fileparse ( $filename, '\..*' );
$filename = $name . $extension;
$filename =~ tr/ /_/;
$filename =~ s/[^$safe_filename_characters]//g;

if($extension !~ /\.csv/i){
  print $query->header();
  print "it's not a csv file, please try again.";
  exit;
}

if ( $filename =~ /^([$safe_filename_characters]+)$/ )
{
 $filename = $1;
}
else
{
 die "Filename contains invalid characters";
}

my $upload_filehandle = $query->upload("csv_file");

open ( UPLOADFILE, "> upload/$collection"."_report.scv" ) or die "$!";
binmode UPLOADFILE;

while ( <$upload_filehandle> )
{
 print UPLOADFILE;
}

close UPLOADFILE;
 
my $CSVFileHandle = new FileHandle;
$CSVFileHandle->open("< upload/$collection"."_report.scv");

# process the csv file
process_access_report($CSVFileHandle, $reportFile, $collection);

print $query->header ( );
print <<END_HTML;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
   <title>Thanks!</title>
   <style type="text/css">
     img {border: none;}
   </style>
 </head>
 <body>
   <p>Thanks for uploading!</p>
   <p>here is the report: [for $collection]</p>
   <p><a href="$reportFileURL">The report</a></p>
 </body>
</html>
END_HTML
