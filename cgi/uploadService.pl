#!/usr/bin/perl

use strict;
use CGI ':standard';

my $DEBUG = 1; #flag: to print log, set it to 1, other wise set it to 0;
my $level = 0; #indentation of log

#print the log
sub printLOG {
  my ($thingsToPrint, $level) = @_;
  if($DEBUG){
    $level = "    " x $level;
    print LOG $level.$thingsToPrint."\n";
  }
}

if ($DEBUG) {
  my $LOG;
  my $LOGFILE = "./log/eadManager.log";
  open (LOG, ">>".$LOGFILE) or die "Couldn't open $LOGFILE: $!";
  print LOG "\n========================================================================\n\n";
}

printLOG("processing readConf.pl", $level);

do 'readConf.pl';

#ead upload script ed64 8/10

###############################################################################
# Main Body
#------------------------------------------------------------------------------
#calls routine from readConf which parses and assigns conf var and paths to hash
#used in shell scripts
printLOG("Main body:", $level);
my %confHash = createHashConf("../conf/eadpublisher.conf");
outputJSON();
printLOG("end of Main, exit.", $level);
close (LOG);
exit();

##############################################################################
# Start subroutine
##############################################################################
sub printHeader {
  $level += 1;
  printLOG("sub printHeader:", $level);
  print header('application/json');
  my $redirectUrl = "$confHash{'REDIRECT_URI'}";
  $level -= 1;
  return;  
}

sub outputJSON {
  
  $level += 1;
  
  printLOG("sub outputHTML:", $level);
  
  print printHeader();

  if (param("eadFile")) {
  
    my $file = param("eadFile");
    
    # is XML file 
    if ($file =~ /.*?\.xml/) {
      
      # file name has upper case letter
      if ($file =~ /fakepath\\[A-Z]+/) {
	    print "{ \"msg\" : \"All files must be in lower case, rename your file into lower case, and upload it again.\", \"code\" : \"9\" }";
      }

      # file name in lower case letter, we are good to go
      else {
        processUpload();
      }

    }
    
    # user try to upload something else than XML
    else {
      print "{ \"msg\" : \"Files must be a XML file\", \"code\" : \"9\" }";
    }
    
  }
  else {
    print "{ \"msg\" : \"No file uploaded\", \"code\" : \"9\" }";    
  }
  
  $level -= 1;
  
  return;
    
}

sub processUpload {

  $level += 1;
  
  printLOG("sub processUpload:", $level);
   
  # Setting path for upload 
  my $uploadDIR = $confHash{'CONTENT_STAGING_PATH'}."/ead";
  
  my $origPath = $uploadDIR;
  
  # Grabbing specified directory
  my $eadDir =  param("eadDir");

  #appending to preset path
  $uploadDIR .= "/$eadDir";
  
  # Grabbing file 
  my $eadFile = param("eadFile");
  
  # If file doesn't exist
  if (! -s $eadFile) {
    print "{ \"msg\" : \"No contents in file. Please check file\", \"code\" : \"9\" }";
    return;
  }

  # Otherwise continue

  # stripping file name of any forward or backward slashes from name
  $eadFile =~ s/.*[\/\\](.*)/$1/;
    
  # Creating file handle
  printLOG("creating file handle", $level+1);
  my $upload_filehandle = upload("ead");

  # If directory doesn't exist, create specified directory and change permissions to 777 for all users

  if (! -d $uploadDIR) {
    printLOG("$uploadDIR doesn't exist, create one", $level+1);
    mkdir($uploadDIR);
    chmod(0777,$uploadDIR);
  }
  
  my $dtd = "$confHash{'CONTENT_URI'}"."/dtd/ead/ead.dtd";
  
  # Open handle to write
  printLOG("open handle to write", $level+1);
  open UPLOADFILE, ">$uploadDIR/$eadFile.tmp" || die "can't open $eadFile";

  # Making file binary to prevent data corruption
  printLOG("making file binary to prevent data corruption", $level+1);
  binmode UPLOADFILE;

  # Uploading file
  my $eadid = "";
  while ( <$upload_filehandle> ) {
    #printLOG("uploading file...", $level+1);
    $_ =~ s/<\!DOCTYPE.*?ead\.dtd\">//; #stripped out DTD declaration if it exists
    if ($_ =~ /(<ead)([\s|>])(.*)/ &&  $_ !~ /931666-22-9>/) {
      my $rest = $3;
      $_ = "<ead xsi:schemaLocation=\"urn:isbn:1-931666-22-9 http://www.loc.gov/ead/ead.xsd\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:ns2=\"http://www.w3.org/1999/xlink\" xmlns=\"urn:isbn:1-931666-22-9\">";
      if ($rest =~ /<.*?>/) {
	$_ .= $rest;
      }
    }
    if ($_ =~ /<eadid[^>]*>(.*)<\/eadid>/) {
      $eadid = $1;
    }
    # note that this won't handle EADs where there is no namespace and the ead tag spans multiple lines
    # let's hope there are none of those

    print UPLOADFILE;
  }

  #Log an error if an <eadid> could not be extracted
  if (length($eadid) < 1){
    printLOG("Error: Could not find an <eadid> in $eadFile", $level+1);
    print("<html><body>You tried to upload a file that does not contain an &lt;eadid&gt; tag!</body></html>");
    exit;
  }

  #closing file handle after writing
  printLOG("close file handle after writing.", $level+1);
  close UPLOADFILE; 
 
  #rename the file based on the <eadid>
  my $oldFile = $eadFile;
  if(rename("$uploadDIR/$eadFile.tmp", "$uploadDIR/$eadid.xml")){
    printLOG("Renamed $eadFile.tmp to $eadid.xml");
    $eadFile = "$eadid.xml";
  } else {
   printLOG("Error renaming uploaded file");
   die "Error renaming uploaded file";
  }
 
 
  #testing to see if file has been written to the specified location 
  my $fileExist = $uploadDIR."/".$eadFile; 
  #transforming xml into html and XML for SOLR
  my($transform,$url,$transformError) = transformFile($origPath,$eadDir,$eadid);
	printLOG("URL: $url");
  if (-e $fileExist) {
    printLOG("$eadFile: Upload successful.", $level+1);
    chmod(0777,$fileExist);
    print "$oldFile has been successfully uploaded and renamed to $eadFile.";
    my $eadURL = $url;
    $eadURL =~ s/html.*/ead/; 
    $eadURL .= "/$eadDir/$eadFile";
 

    #outputting link to xml EAD
    print "<p>Your EAD finding aid can be previewed here: <a href=\"$eadURL\" target=\"_blank\">$eadURL</a></p>";
  } 
  else {
    printLOG("$eadFile: Upload unsuccessful.", $level+1);
    my $uploadError = "<p>$eadFile: Upload unsuccessful</p>";
    printErr($uploadError);
  }
  if ($transformError !~ /Error/) {
    #outputting link to html finding aid 
    printLOG("HTML transform no error: ", $level+1);
    print "<p>Your HTML finding aid can be previewed here: <a href=\"$url\" target=\"_blank\">$url</a></p>";
  } else {
    printLOG("$transformError", $level+1);
    printErr($transformError);
  }
  $level -= 1;
}

sub transformFile {
  $level += 1;
  printLOG("sub transformFile:", $level);
  my $error = '';
  #grabbing source path, directory, and file
  my ($dataPath,$dir,$eadid) = @_;

  #cgetting the filename without the extension.
  #my $ead_filename = "$1" if $file =~ /(.*?)\.xml/;
  my $eadFile = "$eadid.xml";

  #setting output dir
  my $output = "$confHash{'CONTENT_STAGING_PATH'}/html";
  my $htmlDIR = "$output/$dir";
  #ensure that the solr directories exist
  my $solr1DIR = "$confHash{'CONTENT_STAGING_PATH'}/solr1/$dir";
  my $solr2DIR = "$confHash{'CONTENT_STAGING_PATH'}/solr2/$dir";
  
  # Staging URL for the HTML finding aid:
  my $url = "$confHash{'CONTENT_STAGING_URI'}/html/$dir/$eadid";
  
  # Stagin PATH for the HTML finding aid:
  my $path = "$confHash{'CONTENT_STAGING_PATH'}/html/$dir/$eadid";

  #ensure that output dirs exists
  if (! -d $htmlDIR) {
    printLOG("$htmlDIR doesn't exist, create one.", $level+1);
    mkdir($htmlDIR);
    chmod(0777,$htmlDIR);
  }
  if (! -d $solr1DIR){
	  mkdir($solr1DIR);
	  chmod(0777,$solr1DIR);
  }
  if (! -d $solr2DIR){
	  mkdir($solr2DIR);
	  chmod(0777,$solr2DIR);
  }
  
  #Transform and write the HTML mini-site for the finding aid
  my $cmd = "$confHash{'APP_PATH'}/bin/do-ead-transforms.bash $dir/$eadid";
  printLOG("RUNNING COMMAND: $cmd\n");
	my $transform = `$cmd`;
	print $transform;
	
	if ($transform =~ /<eadid>(.*)<\/eadid>/) {
  	if (! $eadid == $1){
  	  printLOG("WARNING: Mismatched eadid values. Was expecting $eadid and got $1 from the transformer");
	  }
	} else {
		printLOG("Error - no eadid returned by the transformer");
	}

  printLOG("transform: $transform", $level + 1);
 
  if ($transform =~ /rror/) {
    printLOG("Transform Error for $eadid: $transform", $level+1);
    $transform =~ s/.*?(Err.*)/$1/is;
    $error .= "<p><b>Transform Error for $eadid:</b> $transform</p>";
  }

  # Make the finding aid files group (apache) writeable - sometimes we want to rewrite these from the CLI
  if ( -d $path){
	  chmod(0777,$path);
	  opendir (DIR, $path);
	  while (my $file = readdir(DIR)) {
		  if ($file =~/\.h?[tx]ml/) {
			  chmod(0775,"$path/$file");
		  }
	  }
	  closedir(DIR);
  }

  #Transform and write the SOLR input files
  $cmd = "$confHash{'APP_PATH'}/bin/do-solr.bash $dir/$eadid";
  printLOG("RUNNING COMMAND: $cmd\n");
  my $transform2 = `$cmd`;
  my $solrFile = '';
  print $transform2;
  if ($transform2 =~ /<solrFile>(.*)<\/solrFile>/) {
    $solrFile = $1;
    printLOG("Solr File: $solrFile\n");
  } else {
    printLOG("Error - no Solr file returned by the transformer");
  }  
  printLOG("transform: $transform2", $level + 1);

  $level -= 1;
  return ($transform,$url,$error);
}

sub printErr {
  my $err = shift;
  $level += 1;
  printLOG("sub printErr: $err", $level);
  print $err;
  $level -= 1;
}

sub getUserID {
  $level += 1;
  printLOG("sub getUserID:", $level);
  my $ticket = shift;
  my $BACKEND_HOST        = 'http://localhost';
  my $BACKEND_PORT        = 41011;
  my $BACKEND_MOUNT_POINT = '/authn';
  my $BACKEND_METHOD      = 'get_user_id_from_ticket';
  #url constructed like this - localhost:port/mount_point
  my $url = "$BACKEND_HOST:$BACKEND_PORT$BACKEND_MOUNT_POINT";
  my $server = Frontier::Client->new('url' => $url);
  #call method returns a reference to result hash
  my $resultStr_ref = $server->call($BACKEND_METHOD, $ticket);
  #dereferencing hash
  my %result = %$resultStr_ref;
  if ($result{'status'} eq 'yes') {
    #stripping out @nyu.edu from user id returned by server
    my $usrID = $1 if $result{'user_id'} =~ /(.*?)\@nyu/;
    $level -= 1;
    return $usrID;
  } else {
    printErr("Invalid Connection. Please login again");
    printLOG("exit from getUserID.", $level+1);
    close (LOG);
    $level -= 1;
    exit();
  }
  $level -= 1;
}

sub chkUserID {
  $level += 1;
  printLOG("sub chkUserID:", $level);
  my $usrID = shift;
  my $status = "false";
  my @allowedUsers = ('ed64','bjh6','jmb583','nc3','ld819','ab20');

  foreach (@allowedUsers) {
    if ($_ eq $usrID) {
      printLOG("find user $usrID", $level+1);
      $status = "true";
      last;
    }
  }
  $level -= 1;
  return $status;
}
