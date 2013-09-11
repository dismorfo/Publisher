#!/usr/bin/perl

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
do 'readConf.pl';


#ead upload script ed64 8/10
###############################################################################
# Main Body
#------------------------------------------------------------------------------
#calls routine from readConf which parses and assigns conf var and paths to hash
#used in shell scripts
my %confHash = createHashConf("../conf/eadpublisher.conf");

remove();

exit();

###############################################################################
#start subroutine
##############################################################################
sub remove
{
    my $status;
    #grabbing file 
    my $eadFile = param("eadFile");
    my $dir = $1 if $eadFile =~ /(.*?)_.*/;
    my $file = $1 if $eadFile =~ /.*?_(.*)/;

    my $staging = "$confHash{'CONTENT_STAGING_PATH'}/html/$dir/$file";
    my $stagingURL = "$confHash{'CONTENT_STAGING_URI'}/html/$dir/$file";
    my $removed;
 
    my $deploy='';
    #print html page
    print header;

    my $deployEad = $confHash{'APP_PATH'} . "/bin/remove-staging.bash";
    if (-x $deployEad){
      my @args = ($deployEad, "$dir/$file");
      $removed = system(@args);
    }else{
      print "The following file is not executable: $deployEad";
    }

    if (! -e $staging && $removed == 0){ 
    print "<a href=\"$stagingURL\">$stagingURL</a> has been successfully removed";
    }
    else{
	print "<br />There was a problem: this file either still exist or has not been indexed: <br />$stagingURL <br />";
    }

}

