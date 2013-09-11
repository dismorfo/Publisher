#!/usr/bin/perl -w

use strict;

my $UID2URI_hash_file = "./uidhash/uid2uri.hash";

my $delimiter = ">>==>>==>>";

#find UID
sub get_UID_from_ead{
  my $eadFile = shift;
  open (my $in, $eadFile) or die "Conldn't read $eadFile : $!";
  my $UID;
  while(<$in>){
    my $line = $_;
    if($line =~ s/^.*<unitid.*>(.+)<\/unitid>.*$/$1/g){
      $UID = normal_unitid($line);
    }
  }
  close $in;
  return $UID;
}

#normalize the unitid
sub normal_unitid{
  if(defined(my $UID = shift)){
    $UID =~ s/^\s*(.*)\s*$/$1/; #strip ws
    $UID =~ s/\s/_/g; #turn ws into _
    return $UID;
  }
}


#write UID2URI hash into a file
sub write_UID_hash{
  my $hashRef = shift;
  open(HASHFILE, '>', $UID2URI_hash_file) || die "can't open file $UID2URI_hash_file";
  while ( my ($key, $value) = each(%$hashRef) ) {
    print HASHFILE "$key$delimiter$value\n";
  }

  close(HASHFILE);
}

#read UID2URI hash from a file
sub read_UID_hash{
  open(HASHFILE, $UID2URI_hash_file) || die "can't open file $UID2URI_hash_file";
  my %UID2URIHash;
  while (my $line = <HASHFILE>) {
    chop($line);
    (my ($key, $value)) = ($line =~ /^(.*)$delimiter(.*)$/);
    if($key ne ""){
      $UID2URIHash{$key} = $value;
    }
  }
  close(HASHFILE);
  return %UID2URIHash;
}
