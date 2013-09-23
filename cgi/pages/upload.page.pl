#!/usr/bin/perl

use Cwd;
use strict;
use File::Copy;

my $dir = cwd();

# load settings and configuration options
do $dir . 'cgi/inc/readConf.pl';

# cast loaded settings and configuration into a hash
my %confHash = createHashConf('conf/eadpublisher.conf');

sub processUpload {
	
  # Grab file
  my $eadFile = param("eadfile");

  # Grab file dir
  my $eadDir =  param("eaddir");

  # 3 tests to fail as fast as we can
  
  # 1: Test arguments: eadFile and eadDir
  if (!$eadFile || !$eadDir) {
    return '<p>A problem was fount with the request; please try again.</p>';
  }
  
  # 2: Test for upper case letter	
  my $upper_case_letters = $eadFile =~ tr/A-Z//;
  
  if ($upper_case_letters != 0) {
    return '<p>All files must be in lower case, rename your file (' . $eadFile . ') into lower case, and upload them again.</p>';
  }
  
  # 3: Test file
  if (! -s $eadFile) {
    return '<p>No contents in file. Please check file.</p>';
  }
  
  # We are clear to continue

  # prepare for return message
  my $output = '';

  # uploading file
  my $eadid = '';

  my $dtd = $confHash{'CONTENT_URI'} . '/dtd/ead/ead.dtd';

  # setting path for upload 
  my $uploadDIR = $confHash{'CONTENT_STAGING_PATH'} . '/ead';

  my $origPath = $uploadDIR;

  # appending to preset path
  $uploadDIR .= '/' . $eadDir;

  # stripping file name of any forward or backward slashes from name
  $eadFile =~ s/.*[\/\\](.*)/$1/;

  # file handle
  my $upload_filehandle = upload("eadfile");
  
  # rename the file based on the <eadid>
  my $oldFile = $eadFile;

  # if directory doesn't exist, create specified directory
  if (! -d $uploadDIR) {
    mkdir($uploadDIR);
    chmod(0775, $uploadDIR);
  }

  # open handle to write
  open UPLOADFILE, ">$uploadDIR/$eadFile.tmp" || return "<p>Unexpected error. Can't open " . $eadFile . " file.</p>";

  # Prevent data corruption
  binmode UPLOADFILE;

  while ( <$upload_filehandle> ) {
    # stripped out DTD declaration if it exists
    $_ =~ s/<\!DOCTYPE.*?ead\.dtd\">//;
        
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
        
    if ($eadid =~ /\s+/) {
      close UPLOADFILE;
      return '<p>Invalid EAD. Please remove any whitepace from the EAD ID.</p>'; 
    }
        
    # Note that this won't handle EADs where there is no namespace and the ead tag spans multiple lines let's hope there are none of those 
    print UPLOADFILE;
  }
  
  # close file handle after writing
  close UPLOADFILE;

  # Log an error if an <eadid> could not be extracted
  if (length($eadid) < 1) {
    return '<p>You tried to upload a file that does not contain an &lt;eadid&gt; tag!</p>';
  }

  if (rename($uploadDIR . '/' . $eadFile . '.tmp', $uploadDIR . '/' . $eadid . '.xml')) {
    $eadFile = $eadid . '.xml';
  }

  else {
    return '<p>Error renaming uploaded file.</p>';
  }

  # transforming xml into html and XML for SOLR
  my ($transform, $url, $transformError) = transformFile($origPath, $eadDir, $eadid);
              
  my $fileExist = $uploadDIR . '/' . $eadFile;

  # Test if file has been written to the specified location      
  if (-e $fileExist) {

    chmod(0775, $fileExist);
        
    my $eadURL = $url;
        
    $eadURL =~ s/html.*/ead/; 
        
    $eadURL .= '/' . $eadDir . '/' . $eadFile;
        
    $output .= '<div class="eadid" data-eadid="' . $eadid .'" data-xml="' . $eadURL . '" data-html="' . $url . '" data-repo="' . $eadDir .'" data-publicate="' . $confHash{'PUBLISHER_URI'} . '/publicate/' . $eadDir . '/' . $eadid . '" data-delete="' . $confHash{'PUBLISHER_URI'} . '/delete/' . $eadDir . '/' . $eadid . '" data-inner="' . $confHash{'CONTENT_STAGING_URI'} . '/solr2/' . $eadDir . '/' . $eadid . '.solr.xml" data-outer="' . $confHash{'CONTENT_STAGING_URI'} . '/solr1/' . $eadDir . '/' . $eadid . '.solr.xml">';

    # Output file link
    $output .= '<p>' . $oldFile . ' has been successfully uploaded and renamed to ' . $eadFile . '.</p>';

    # Output XML link 
    $output .= '<p>Your EAD finding aid can be previewed here: <a class="ead" href="'. $eadURL . '" target="_blank">' . $eadURL . '</a></p>';
    
    # Output HTML link 
    if ($transformError !~ /Error/) {
      $output .= '<p>Your HTML finding aid can be previewed here: <a class="html" href="' . $url . '" target="_blank">' . $url . '</a></p>';
    }

    $output .= '</div>';
    
    return $output; 

  }
  
  else {
    $output .= '<p>Unable to upload ' . $eadFile . ' an error occur, please make sure you have a valid EAD and try again.</p>';
  }
  

  
  # there was a error 
  #else {
  #  $output .= $transformError;
  #}
        
  # open (MYFILE, '>>data.txt');
  # print MYFILE "Bob\n";
  # close (MYFILE); 
        
}
    

sub transformFile {

  my $error = '';

  # grabbing source path, directory, and file
  my ($dataPath, $dir, $eadid) = @_;

  # getting the filename without the extension.
  my $eadFile = $eadid . '.xml';

  # setting output dir
  my $output = $confHash{'CONTENT_STAGING_PATH'} . '/html';
  
  my $htmlDIR = $output . '/' . $dir;
  
  # ensure that the solr directories exist
  my $solr1DIR = $confHash{'CONTENT_STAGING_PATH'} . '/solr1/' . $dir;
  
  my $solr2DIR = $confHash{'CONTENT_STAGING_PATH'} . '/solr2/' . $dir;
  
  # staging URL for the HTML finding aid:
  my $url = $confHash{'CONTENT_STAGING_URI'} . '/html/' . $dir . '/' . $eadid;
  
  # stagin PATH for the HTML finding aid:
  my $path = $confHash{'CONTENT_STAGING_PATH'} . '/html/' . $dir . '/' . $eadid;  
  
  # ensure that output dirs exists
  if (! -d $htmlDIR) {
    mkdir($htmlDIR);
    chmod(0777, $htmlDIR);
  }
  
  if (! -d $solr1DIR) {
    mkdir($solr1DIR);
    chmod(0777, $solr1DIR);
  }
  
  if (! -d $solr2DIR) {
	mkdir($solr2DIR);
	chmod(0777, $solr2DIR);
  }

  # transform and write the HTML mini-site for the finding aid
  my $cmd = $confHash{'APP_PATH'} . '/bin/do-ead-transforms.bash ' . $dir . '/' . $eadid;
  
  my $transform = `$cmd`;
  
  if ($transform =~ /<eadid>(.*)<\/eadid>/) {
    if (! $eadid == $1) {
  	  $error .= '<p>WARNING: Mismatched eadid values. Was expecting ' . $eadid . ' and got ' . $1 . ' from the transformer.</p>';
	}
  }
  else {
    $error .= '<p>Error - no eadid returned by the transformer</p>';
  }

  if ($transform =~ /rror/) {
    $transform =~ s/.*?(Err.*)/$1/is;
    $error .= '<p>Transform Error for ' . $eadid . ' : ' . $transform . '</p>';
  }

  # Make the finding aid files group (apache) writeable - sometimes we want to rewrite these from the CLI
  if ( -d $path) {
    chmod(0777, $path);
	opendir (DIR, $path);
	while (my $file = readdir(DIR)) {
	  if ($file =~/\.h?[tx]ml/) {
        chmod(0775, $path . '/' . $file);
      }
    }
    closedir(DIR);
  }

  # Transform and write the SOLR input files
  $cmd = $confHash{'APP_PATH'} . '/bin/do-solr.bash ' . $dir .'/' . $eadid;
  
  my $transform2 = `$cmd`;
  
  my $solrFile = '';
  
  if ($transform2 =~ /<solrFile>(.*)<\/solrFile>/) {
    $solrFile = $1;
  }

  else {
    $error .= '<p>Error - no Solr file returned by the transformer</p>';
  }
  
  return ($transform, $url, $error);

}