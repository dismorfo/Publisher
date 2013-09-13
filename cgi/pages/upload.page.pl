#!/usr/bin/perl

use Cwd;
use strict;

my $dir = cwd();

# load settings and configuration options
do $dir . 'cgi/inc/readConf.pl';

# cast loaded settings and configuration into a hash
my %confHash = createHashConf('conf/eadpublisher.conf');

sub uploadFile {
	
  my ($identifier) = @_;
  
  # collections look up
  my %collections = listOfCollections();

  my $collections_output = '';
  
  # iterate collections and build the html to be render
  for (keys %collections) {
  	if ($_ eq $identifier) {
  	  $collections_output .= '<option value="' . $_ . '" selected>' . $collections{$_} . '</option>';
  	}
  	else {
  	  $collections_output .= '<option value="' . $_ . '">' . $collections{$_} . '</option>';	
  	}
  }

  my $uploadFile = qq#
    <div class="container msg"></div>
    <div class="overlay">
      <div id="panelContent">
        <div class="yui3-widget-bd"></div>
      </div>
      <div id="nestedPanel"></div>
    </div>
    <form id="upload-ead" method="post" action="$confHash{'PUBLISHER_URI'}/upload" enctype="multipart/form-data">
      <div id="Upload">
        <h3>Upload file</h3>
        <select name="eaddir" id="eaddir">
          <option value="select">Please select archive:</option>
          $collections_output
	    </select>
        <input type="file" name="eadfile" id="eadfile"/>
        <input type="hidden" name="pjax" value="true"/>
        <p><input type="submit" value="Upload EAD"></input></p>
      </div>
    </form>
  #;
  return $uploadFile;
}

sub processUpload {

  my $output = '';

  # grabbing file
  my $eadFile = param("eadfile");

  # grabbing file dir
  my $eadDir =  param("eaddir");

  if ($eadFile && $eadDir) {
  	
    my $dtd = $confHash{'CONTENT_URI'} . '/dtd/ead/ead.dtd';

    # test for upper case letter	
  	my $upper_case_letters = $eadFile =~ tr/A-Z//;

  	# check if file name has upper case letter
    if ($upper_case_letters == 0) {
    	
      # setting path for upload 
      my $uploadDIR = $confHash{'CONTENT_STAGING_PATH'} .'/ead';
  
      my $origPath = $uploadDIR;

      # appending to preset path
      $uploadDIR .= '/' . $eadDir;
 
      # if file doesn't exist
      if (! -s $eadFile) {
        $output .= '<p>No contents in file. Please check file</p>';
      }

      # otherwise continue
      # stripping file name of any forward or backward slashes from name
      $eadFile =~ s/.*[\/\\](.*)/$1/;

      # creating file handle
      my $upload_filehandle = upload("eadfile");

      # if directory doesn't exist, create specified directory and change permissions to 777 for all users
      if (! -d $uploadDIR) {
        mkdir($uploadDIR);
        chmod(0777, $uploadDIR);
      }
  
      # open handle to write
      open UPLOADFILE, ">$uploadDIR/$eadFile.tmp" || die "can't open $eadFile";

      # making file binary to prevent data corruption
      binmode UPLOADFILE;

      # uploading file
      my $eadid = "";
        
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
        
        # note that this won't handle EADs where there is no namespace 
        # and the ead tag spans multiple lines let's hope there are 
        # none of those
        print UPLOADFILE;
      }

      # Log an error if an <eadid> could not be extracted
      if (length($eadid) < 1){
        $output .= '<p>You tried to upload a file that does not contain an &lt;eadid&gt; tag!</p>';
        return $output;
      }

      # closing file handle after writing
      close UPLOADFILE; 
 
      # rename the file based on the <eadid>
      my $oldFile = $eadFile;
        
      if (rename($uploadDIR . '/' . $eadFile . '.tmp', $uploadDIR . '/' . $eadid . '.xml')) {
        $eadFile = $eadid . '.xml';
      }
      else {
        $output .= '<p>Error renaming uploaded file.</p>';
      }
 
      # testing to see if file has been written to the specified location 
      my $fileExist = $uploadDIR . '/' . $eadFile;
         
      # transforming xml into html and XML for SOLR
      my($transform, $url, $transformError, $msg) = transformFile($origPath, $eadDir, $eadid, '');
        
      $output .= '<p>origPath: ' . $origPath . '</p>';
      
      $output .= '<p>eadDir: ' . $eadDir . '</p>';
      
      $output .= '<p>eadid: ' . $eadid . '</p>';
        
      if (-e $fileExist) {
        
        chmod(0777, $fileExist);
        
        $output .= '<p>' . $oldFile . ' has been successfully uploaded and renamed to ' . $eadFile . '.</p>';
        
        my $eadURL = $url;
        
        $eadURL =~ s/html.*/ead/; 
        
        $eadURL .= '/' . $eadDir . '/' . $eadFile;

        # outputting link to xml EAD
        $output .= '<p>Your EAD finding aid can be previewed here: <a href="'. $eadURL . '" target="_blank">' . $eadURL . '</a></p>';
      } 
      else {
        $output .= '<p>Unable to upload ' . $eadFile . ' an error occur, please make sure you have a valid EAD and try again.</p>';
      }
      
      if ($transformError !~ /Error/) {
        # outputting link to html finding aid
        
        $output .= $transformError;
         
        $output .= '<p>Your HTML finding aid can be previewed here: <a href="' . $url . '" target="_blank">' . $url . '</a></p>';
      } 
      else {
        $output .= $transformError;
      }
    }
	else {
	  $output .= '<p><strong>Error!</strong> ' . $eadFile . ' must be in lower case. All files must be in lower case, rename your file into lower case, and upload them again.</p>';
    }
  }
}

sub transformFile {

  my $error = '';
  
  my $msg = '';

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
  
  $msg .= 'RUNNING COMMAND: ' . $cmd;
  
  my $transform = `$cmd`;
  
  if ($transform =~ /<eadid>(.*)<\/eadid>/) {
    if (! $eadid == $1){
  	  $error .= 'WARNING: Mismatched eadid values. Was expecting ' . $eadid . ' and got ' . $1 . ' from the transformer.';
	}
  }
  else {
    print 'Error - no eadid returned by the transformer';
  }

  if ($transform =~ /rror/) {
      $transform =~ s/.*?(Err.*)/$1/is;
      $error .= 'Transform Error for ' . $eadid . ' : ' . $transform;
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
  
  $msg .= 'RUNNING COMMAND: ' . $cmd;
  
  my $transform2 = `$cmd`;
  
  my $solrFile = '';
  
  if ($transform2 =~ /<solrFile>(.*)<\/solrFile>/) {
    $solrFile = $1;
    $msg .= 'Solr File: ' . $solrFile;
  }
  else {
    $error .= "Error - no Solr file returned by the transformer";
  }  

  return ($transform, $url, $error, $msg);
}