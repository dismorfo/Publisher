#!/usr/bin/perl -w


#########################################################
#  create hash table for UID -> URI pair from all files
#########################################################


use strict;
use CGI ':standard';
#use CGI::Carp qw ( fatalsToBrowser );
#use File::Basename;

do 'readConf.pl';#for createHashConf
do 'auxiliary.pl';#for read write hash table get_UID_from_ead ...

my %confHash = createHashConf("../conf/eadpublisher.conf");

my %UID2URIHash;

my $eadDir = "$confHash{CONTENT_PATH}/ead";
my $uri = "http://dlib.nyu.edu/findingaids/html/";

opendir(DIR, $eadDir) or die "can't opendir $eadDir: $!";
my $subDirs;
while (defined($subDirs = readdir(DIR))) {#for all sub directory
  if($subDirs !~ m{^\.}){#file not start with "."
    opendir(SUB_DIR, "$eadDir/$subDirs") or die "can't opendir $eadDir/$subDirs: $!";
    my $eadFile;
    while (defined($eadFile = readdir(SUB_DIR))) {#for all file
      if($eadFile =~ m{.xml$}){
	print "$eadDir/$subDirs/$eadFile\n";
	my $UID = get_UID_from_ead("$eadDir/$subDirs/$eadFile");
	if(defined($UID)){
	  #$UID2URIHash{$UID} = "$eadDir/$subDirs/$eadFile";
	  $UID2URIHash{"$subDirs"."_$UID"} = "$subDirs/$eadFile";
	}
      }
    }
  }
}

write_UID_hash(\%UID2URIHash);

#test
while ( my ($key, $value) = each(%UID2URIHash) ) {
  print "$key => $value\n";
}
closedir(DIR);
