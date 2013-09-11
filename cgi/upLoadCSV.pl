#!/usr/bin/perl -wT

use strict;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;


my $safe_filename_characters = "a-zA-Z0-9_.-";
my $upload_dir = "./upload";

my $query = new CGI;
my $filename = $query->param("csv_file");

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

open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "$!";
binmode UPLOADFILE;

while ( <$upload_filehandle> )
{
 print UPLOADFILE;
}

close UPLOADFILE;

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
   <p>Your file: $filename</p>
   <p><a href="$upload_dir/$filename">THE CSV FILE</a></p>
 </body>
</html>
END_HTML
