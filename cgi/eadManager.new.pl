#!/usr/bin/perl

use strict;
use CGI ':standard';
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
#use FileHandle;

#do 'auxiliary.pl';
#do 'accessReport.pl';

#use XML::Parser::Expat;
#use lib '/usr/cluster/lib/perl/';
#use Frontier::Client;
my $DEBUG = 1; #flag: to print log, set it to 1, other wise set it to 0;
my $level = 0; #indentation of log

#print the log
sub printLOG{
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
outputHTML();
printLOG("end of Main, exit.", $level);
close (LOG);
exit();

##############################################################################
#start subroutine
##############################################################################
sub printHeader{
  $level += 1;
  printLOG("sub printHeader:", $level);
  #print html page
  print header;
  my $redirectUrl = "$confHash{'REDIRECT_URI'}";
  my $header = qq#
  <!doctype html>
      <html lang="en">
      <head>
        <title>EAD Preview</title>
        <meta charset="utf-8">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="http://yui.yahooapis.com/pure/0.2.1/pure-min.css">
        <link rel="stylesheet" href="/findingaids/publisher/css/base.css">
        <script src="http://use.typekit.net/ajf8ggy.js"></script>
        <script>try { Typekit.load(); } catch (e) {}</script>
      </head>
  #;
  $header .= '<body class="yui3-skin-sam">';
  $level -= 1;
  return $header;  
}

sub printNavigation {
  
  my $navigation = qq#
  <div class="header">
    <div class="pure-menu pure-menu-open pure-menu-fixed pure-menu-horizontal">
      <a class="pure-menu-heading" href="/findingaids/publisher">EAD Publisher</a>
      <ul>
        <li class="pure-menu-selected"><a href="/findingaids/publisher/">Home</a></li>
        <li><a href="/findingaids/publisher/cgi/eadManager.upload.pl">Upload EAD</a></li>
        <li><a href="/findingaids/publisher/cgi/eadManager.publish.pl">Review / publish finding aids</a></li>
        <li><a href="/findingaids/publisher/cgi/eadManager.published.pl">Review published finding aids</a></li>        
        <li><a href="/findingaids/publisher/cgi/upload_csv.html">Process accessions report</a></li>
      </ul>
    </div>
  </div>
  #;
  return $navigation;  
}

sub outputHTML {
  $level += 1;
  printLOG("sub outputHTML:", $level);
  print printHeader();

  if (param("ead")) {
    my $file = param("ead");
    if ($file =~ /.*?\.xml/) {
      # file name has upper case letter
      if ($file =~ /.*[A-Z]+.*/) {
	    my $uploadDir = param("dir");
	    my $publishedXml = "$confHash{'CONTENT_PATH'}/ead/$uploadDir/$file";
	    # already published
	    if (-e $publishedXml) {
	      processUpload();
	    }
	    else {
	      my $err = "<h1><b>Error! </b> $file must be in lower case</h1>\nStarting from May 8 2009, all files must be in lower case, rename your file into lower case, and upload them again.";
	      printErr($err);
	    }
      }
      else {
	    processUpload();
      }
    }
    else {
      my $err = "<b>Error!</b> $file must be a xml file";
      printErr($err);
    }
  }
  else {
    printErr("No file uploaded");
  }
  
  print printNavigation();

  # list EAD files
  my $files = lsFiles();
  
  my $body = qq#
    <div class="main">
      <div class="body">
        <div class="content">$files</div>
      </div>
    </div>
  #;
  
  print $body;

  # finish up html page
  
  print printScripts();
  
  print end_html();
  
  $level -= 1;
}

sub printScripts {
  my $scripts = qq#
  <script src="http://yui.yahooapis.com/3.12.0/build/yui/yui-min.js"></script>
  <script src="$confHash{'APP_URI'}/js/ui.js"></script>
  #;
  return $scripts;
}

sub lsFiles {

  $level += 1;
  printLOG("sub lsFiles:", $level);
  
  my $archives = outputFiles("archives","University Archives");
  my $fales = outputFiles("fales","Fales");
  my $tamwag = outputFiles("tamwag","Tamiment-Wagner");
  my $nyhs = outputFiles("nyhs","NYHS");
  my $rism = outputFiles("rism","Research Institute for the Study of Man");
  my $bhs = outputFiles("bhs","Brooklyn Historical Society");
  my $poly = outputFiles("poly","Poly Archives");
  
  my $body = qq#
      <form name="publish" class="pure-form pure-form-stacked">
        <fieldset>
          <legend>Review / publish pending finding aids</legend>
        </fieldset>
        <div id="collections">
          <ul>
            <li><a href="\#archives">University Archives</a></li>
            <li><a href="\#fales">Fales</a></li>
            <li><a href="\#tamwag">Tamiment-Wagner</a></li>
            <li><a href="\#nyhs">NYHS</a></li>            
            <li><a href="\#rism">Research Institute for the Study of Man</a></li>
            <li><a href="\#bhs">Brooklyn Historical Society</a></li>
            <li><a href="\#poly">Poly Archives</a></li>
          </ul>
          <div>
            <div id="archives">$archives</div>
            <div id="fales">$fales</div>
            <div id="tamwag">$tamwag</div>
            <div id="nyhs">$nyhs</div>
            <div id="rism">$rism</div>
            <div id="bhs">$bhs</div>
            <div id="poly">$poly</div>
          </div>
        </div>
      </form>
  #;
  
  return $body;
  
  print "<p style=\"padding-top:2%; padding-bottom:2%;font-weight:bold;font-size:120%\">3. Review published finding aids</p>";
  print "<table width = \"80%\"cellspacing=\"4\">";
  print "<tr>";
  print "<td valign=\"top\">";
  
  # showPublished("archives","University Archives");
  
  print "</td>";
  print "<td valign=\"top\">";
  
  # showPublished("fales","Fales");
  
  print "</td>";
  print "<td valign=\"top\">";
  
  # showPublished("tamwag","Tamiment-Wagner");
  
  print "</td>";
  print "<td valign=\"top\">";
  
  # showPublished("nyhs","NYHS");
  
  print "</td>";
  print "<td valign=\"top\">";
  
  # showPublished("rism","Research Institute for the Study of Man");
  
  print "</td>";
  print "<td valign=\"top\">";
  
  # showPublished("bhs","Brooklyn Historical Society");
  
  print "</td>";
  print "<td valign=\"top\">";
  
  # showPublished("poly","Poly Archives");
  
  print "</td>";
  print "</tr>";
  print"<tr>";
  print "</table>";
  
  $level -= 1;
}

sub outputFiles {
  $level += 1;
  printLOG("sub outputFiles:", $level);
  
  my ($dir,$heading) = @_;
  
  my $previewDir = "$confHash{'CONTENT_STAGING_PATH'}/html";
  
  my @pendingEAD = `ls $previewDir/$dir/`;
  
  my $tbody = "";
  
  foreach (@pendingEAD) {
    unless ($_ =~ /_content\.html/ || $_ =~ /_toc\.html/) {
      chop($_);
      $_ =~ s/.*\/(.*).html/$1/;
      my $id = "$dir\_$_";
      $tbody .= "<tr>";
      $tbody .= "<td>$_</td>";
      $tbody .= "<td><a href=\"$confHash{'CONTENT_STAGING_URI'}/ead/$dir/$_.xml\">EAD</a></td>";
      $tbody .= "<td><a href=\"$confHash{'CONTENT_STAGING_URI'}/ead/$dir/$_.xml\">HTML</a></td>";      
      $tbody .= "<td><a href='#' onclick=\"callScript('$id','publish.pl','publish')\">Publish</a></td>";
      $tbody .= "<td><a href='#' onclick=\"callScript('$id','remove.pl','remove')\">Remove</a></td>";
      $tbody .= "</tr>";
    }
  }
  
  my $body = qq#
    <h3 class="title hidden">$heading</h3>
    <table class='tab-table pure-table pure-table-bordered pure-table-striped'>
      <thead>
        <tr>
          <th>Identifier</th>
          <th colspan="2" class="preview">Preview</th>
          <th colspan="2" class="actions">Actions</th>
        </tr>
      </thead>
      <tbody>$tbody</tbody>
    </table>
  #;
  
  return $body;
  
  $level -= 1;
}

sub processUpload {
  $level += 1;
  printLOG("sub processUpload:", $level);
  #this is just copied from upload.pl, with the outer html stuff removed
   
  #setting path for upload 
  my $uploadDIR = $confHash{'CONTENT_STAGING_PATH'}."/ead";
  my $origPath = $uploadDIR;
  #grabbing specified directory
  my $eadDir =  param("dir");

  #appending to preset path
  $uploadDIR .= "/$eadDir";
  #grabbing file 
  my $eadFile = param("ead");
 
  #if file doesn't exist
  if (! -s $eadFile) {
    my $sizeErr = "<h1>No contents in file. Please check file</h1>";
    printErr($sizeErr);
  }

  #otherwise continue
  #stripping file name of any forward or backward slashes from name
  $eadFile =~ s/.*[\/\\](.*)/$1/;
    
  #creating file handle
  printLOG("creating file handle", $level+1);
  my $upload_filehandle = upload("ead");

  #if directory doesn't exist, create specified directory and change permissions to 777 for all users
  #print $uploadDIR;
  if (! -d $uploadDIR) {
    printLOG("$uploadDIR doesn't exist, create one", $level+1);
    mkdir($uploadDIR);
    chmod(0777,$uploadDIR);
  }
  my $dtd = "$confHash{'CONTENT_URI'}"."/dtd/ead/ead.dtd";
  #open handle to write
  printLOG("open handle to write", $level+1);
  open UPLOADFILE, ">$uploadDIR/$eadFile.tmp" || die "can't open $eadFile";

  #making file binary to prevent data corruption
  printLOG("making file binary to prevent data corruption", $level+1);
  binmode UPLOADFILE;

  #uploading file
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
 

    ###############################################
    #      finding aid hash insert goes here      #
    ###############################################
    #my $UID = get_UID_from_ead($fileExist);
    #if(defined($UID)){
    #  my %UID2URIHash = read_UID_hash();
    #  $UID2URIHash{"$eadDir"."_$UID"} = "$eadDir/$eadFile";
    #  write_UID_hash(\%UID2URIHash);
    #}
    #my $CSVFileHandle = new FileHandle;
    #$CSVFileHandle->open("< upload/$eadDir"."_report.scv");
    #y $reportFile = "./report/$eadDir"."_report.html";
    # process the csv file
    # process_access_report($CSVFileHandle, $reportFile, $eadDir);
    # print "<p>The updated access report can be found here: <a href=\"$reportFile\" target=\"_blank\">$reportFile</a></p>";
    ################################################

    #outputting link to xml EAD
    print "<p>Your EAD finding aid can be previewed here: <a href=\"$eadURL\" target=\"_blank\">$eadURL</a></p>";
  } else {
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

sub transformFile{
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

sub printErr{
  my $err = shift;
  $level += 1;
  printLOG("sub printErr: $err", $level);
  print $err;
  $level -= 1;
}

sub getUserID{
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

sub chkUserID{
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

sub showPublished{
  $level += 1;
  printLOG("sub showPublished:", $level);
  #copied from outputFiles
  my ($dir,$heading) = @_;
  my $previewDir = "$confHash{'CONTENT_PATH'}/html";
  my @publishedEAD = `ls $previewDir/$dir/`;

  print "<b>$heading</b>";
  print "<table cellspacing=\"4\" width=\"80%\">";
  foreach (@publishedEAD) {
    #printLOG("foreach publishedEAD", $level+1);
    unless ($_ =~ /_content\.html/ || $_ =~ /_toc\.html/){
      chop($_);
      $_ =~ s/.*\/(.*).html/$1/;
      my $id = "$dir\_$_";
      print "<tr>";
      print "<td id=\"$id\" colspan=\"2\">$_<br />&#160;&#160;<a href=\"$confHash{'CONTENT_URI'}/ead/$dir/$_.xml\">URL: EAD</a><br />&#160;&#160;<a href=\"$confHash{'CONTENT_URI'}/html/$dir/$_\">URL: HTML</a></td>";
      print "</tr>";
    }
  }
  print "</table>";
  $level -= 1;
}