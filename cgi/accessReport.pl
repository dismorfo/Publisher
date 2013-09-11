#!/usr/bin/perl -w

use strict;
use CGI qw/:standard/;

do 'auxiliary.pl';

my $csvFile = "./upload/accessions-record-report.csv";
my $findingAidURL = "http://dlib.nyu.edu/findingaids/html/";
my $reportHtml = "report.html";
my %snippetHash;
my %generalHash;
my %albaHash;
my @snippet;

open (my $in, $csvFile) or die "Conldn't read $csvFile : $!";


while(<$in>){
  my $line = $_;
  push @snippet, $line;

  #end of snippet
  if($line =~ /.*Page\s*\d+\s*of.*\d{4}.*/){ #matchs "Page 3 of,,,, 1484"
    %snippetHash = process_snippet(@snippet);
    if($snippetHash{resourceId} =~ /ALBA/){
      $albaHash{$snippetHash{title}} = {%snippetHash};
    }
    else{
      $generalHash{$snippetHash{title}} = {%snippetHash};
    }
    @snippet = ""; #clear it
  }
}
close $in;
output_report(\%generalHash, \%albaHash, $reportHtml);


##################################################
sub process_access_report{
  do 'auxiliary.pl';
  my ($in, $reportFile, $collection) = @_;
  my %snippetHash;
  my %generalHash;
  my %albaHash;
  my @snippet;
  my %UID2URIHash = read_UID_hash();

  while(<$in>){
    my $line = $_;
    push @snippet, $line;
    
    #end of snippet
    if($line =~ /.*Page\s*\d+\s*of.*\d{4}.*/){ #matchs "Page 3 of,,,, 1484"
      %snippetHash = process_snippet(\@snippet, \%UID2URIHash, $collection);
      if($snippetHash{resourceId} =~ /ALBA/){
	$albaHash{$snippetHash{title}} = {%snippetHash};
      }
      else{
	$generalHash{$snippetHash{title}} = {%snippetHash};
      }
      @snippet = ""; #clear it
    }
  }
  close $in;
  output_report(\%generalHash, \%albaHash, $reportFile, $collection);

}





#################################################
#                  functions
#################################################

#extract information from each snippet
sub process_snippet{
  my ($snippet, $UID2URIHashRef, $collection) = @_;
  my $title;
  my $resourceId;
  my $UID;
  my $resourceTitle;
  my $description;
  my $findingAid;

  for(my$i = 0; $i < @{$snippet}; $i++){
    #title
    if(${$snippet}[$i] =~ /^,*\d{4}\.\d{3}.,.*,+$/){
      my $titleLine = ${$snippet}[$i];
      $titleLine =~ s/^,*\d{4}\.\d{3}.(.*)/$1/;
      if($titleLine =~ /^,*".*",*$/){ # in " quote
	$titleLine =~ s/^,*"(.*)",*$/$1/;
	$title = $1;
      }
      else{
	$titleLine =~ /,*([^,]+),*/;
	$title = $1;
      }
    }
    #resource identifier and resource title
    if(${$snippet}[$i] =~ /^,*resource identifier,*resource title,*$/){
      $i++; #go to next line
      ($resourceId, my $rt) = (${$snippet}[$i] =~ /,*([^,]+),+([^,]+),*/);
      $resourceTitle = $rt if($rt ne "No resource title");
      $UID = normal_unitid($resourceId);
    }
    #description
    if(${$snippet}[$i] =~ /^,*description,*$/){
      $i++; #go to next line
      if(${$snippet}[$i] !~ /,*accession date,*/){#if there's a description
	($description) = (${$snippet}[$i] =~ /^,*([^,].*[^,]),+$/);
	$description =~ s/^"(.*)"$/$1/;
      }
    }
    #findingAid
    if(defined(${$UID2URIHashRef}{"$collection"."_$UID"})){
      $findingAid = ${$UID2URIHashRef}{"$collection"."_$UID"};
    }
  }

  my %snippetHash;
  $snippetHash{title} = $title if(defined($title));
  $snippetHash{resourceId} = $resourceId if(defined($resourceId));
  $snippetHash{resourceTitle} = $resourceTitle if(defined($resourceTitle));
  $snippetHash{description} = $description if(defined($description));
  $snippetHash{UID} = $UID if(defined($UID));
  $snippetHash{findingAid} = $findingAid if(defined($findingAid));

  return %snippetHash;
}


#output the report html
sub output_report{
  my ($genHash, $alHash, $reportFile, $collection) = @_;
  my $collectionIdx = 0;

  my $htmlHeader = '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">

<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>accession report</title>
	<meta name="generator" content="TextMate http://macromates.com/">
	<meta name="author" content="Brian Hoffman 2">
	<style type="text/css" media="screen">
		body {
			background-color: #FFFFCC;
			font-family: "trebuchet MS";	
		}
		

/* Overall Layout*/
		.collection {
			padding-top: 10px;
			padding-bottom: 10px;
			border-top: 1px solid grey;
		}
		
		.title-region {
			float: left;
		}
		
		.description-label {
			float:right;
		}
                .fa-link {
			float:right;
		}		

		.description-region {
			clear:both;
		}
		
/* Specific Formatting */
		.title-region h2 {
			margin: 1px;
			font-size: 1.2em;
		}

		.description {
			display:none;
		}	
		
		
	</style>
	<!-- Date: 2009-06-15 -->
		
	<script language="javascript" src="js/jquery-1.3.2.js"></script>
	
	<script language="javascript">
	function toggleDescription(descriptionId) {
	//	descriptionDiv = document.getElementById(descriptionId);
		$("#" + descriptionId).toggle();
	}
	</script>

	<script language="javascript">

	function toggleAllDescription() {
                var i=1;
                for(i=1; i<2000; i++){
                    if($("#description-"+i).css("display") == "block" || $("#description-"+i).css("display") == "none"){
                        break;
                    }
                }
//alert(i);
//alert($("#description-"+i).css("display"));
                if($("#description-"+i).css("display") != \'block\'){
                        //alert("none");
		        $(\'.description\').css({\'display\' : \'block\'});
                }
                else{
                        //alert("block");
                        $(\'.description\').css({\'display\' : \'none\'});
                }

	}
	</script>

</head>
<body>
	<div id="global-navigation">
		Navigation<br />


                <a href="javascript:void(0);" onclick="toggleAllDescription();">Show/Hide All Descriptions.</a><br />
<!--
                <a href="#" onclick="$(\'.description\').css({\'display\' : \'block\'});">Show All Descriptions.</a><br />

                <a href="#" onclick="$(\'.description\').css({\'display\' : \'none\'});">Hide All Descriptions.</a><br />
-->
		<a href="#general">Manuscripts, Personal Papers, Organizational Records, Oral History, Non-Print and Photograph Collections</a><br />
		<a href="#alba">Abraham Lincoln Brigade Archives (ALBA) Collections</a>
	</div>';

  my $generalList = '        <a name="general"></a>
	<h2>Manuscripts, Personal Papers, Organizational Records, Oral History, Non-Print and Photograph Collections</h2>
';

  my $albaList = '      	<a name="alba"></a>
         <h2>Abraham Lincoln Brigade Archives (ALBA) Collections</h2>
';

  open (my $out, '>', $reportFile) or die "Conldn't read $reportFile : $!";
  print $out $htmlHeader;
  print $out $generalList;
  output_report_body($genHash, $out, \$collectionIdx);
  print $out $albaList;
  output_report_body($alHash, $out, \$collectionIdx);
  print $out end_html;
  close $out;
}

#used by sub output_report, print the body
sub output_report_body{
do 'readConf.pl';#for createHashConf
my %confHash = createHashConf("../conf/eadpublisher.conf");

my ($allHash, $out, $collectionIdx) = @_;
  my $k;
  foreach $k (sort keys %{$allHash} ) {
    ++$$collectionIdx;

    #title and resourceID
    print $out '		<div id="collection-', $$collectionIdx, '" class="collection">
			<div class="title-region"><h2>', ${$allHash}{$k}{title},' (', ${$allHash}{$k}{resourceId}, ')</h2><!--Title + Resource Identifier-->
';

    #finding aid
    if(!defined(${$allHash}{$k}{findingAid})){
      print $out '				<div class="fa-link"></div><!--Leave empty if there is no finding aid-->
			</div>
';

      #description
      if(!defined(${$allHash}{$k}{description})){
	print $out '			<div class="description-label">No Description</div><div class="description-region"><div id="description-num" class="description"></div></div>
';
      }
      else{
	print $out '			<div class="description-label"><a href="javascript:void(0);" onclick="toggleDescription(\'description-', $$collectionIdx, '\');">Description</a></div>
			<div class="description-region">
				<div id="description-', $$collectionIdx, '" class="description">',${$allHash}{$k}{description},'</div>
			</div>
';
      }

    }
    else{
      my $fa = ${$allHash}{$k}{findingAid};
      $fa =~ s/xml$/html/;
      print $out '				</div><div class="fa-link"><a href="',$confHash{CONTENT_URI},'/html/',$fa,'">Finding Aid</a></div>
			<div class="description-label"></div><div class="description-region"><div id="description-num" class="description"></div></div>
';
    }

    print $out '		</div>
';
  }
}
