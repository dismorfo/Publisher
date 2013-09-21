#!/usr/bin/perl

use strict;

# load settings and configuration options
do 'inc/readConf.pl';

# cast loaded settings and configuration into a hash
my %confHash = createHashConf("../conf/eadpublisher.conf");

sub publishedFiles {

  my $archives = showPublished("archives","University Archives");
  my $fales = showPublished("fales","Fales");
  my $tamwag = showPublished("tamwag","Tamiment-Wagner");
  my $nyhs = showPublished("nyhs","NYHS");
  my $rism = showPublished("rism","Research Institute for the Study of Man");
  my $bhs = showPublished("bhs","Brooklyn Historical Society");
  my $poly = showPublished("poly","Poly Archives");
  
  my $body = qq#
      <form name="publish" class="pure-form pure-form-stacked">
        <fieldset>
          <legend>Review published finding aids</legend>
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
}

sub showPublished {
  
  my ($dir,$heading) = @_;
  my $previewDir = "$confHash{'CONTENT_PATH'}/html";
  my @publishedEAD = `ls $previewDir/$dir/`;
  
  my $tbody = "";
  
  foreach (@publishedEAD) {
    unless ($_ =~ /_content\.html/ || $_ =~ /_toc\.html/) {
      chop($_);
      $_ =~ s/.*\/(.*).html/$1/;
      my $id = "$dir\_$_";
      $tbody .= "<tr>";
      $tbody .= "<td>$_</td>";
      $tbody .= "<td><a href=\"$confHash{'CONTENT_URI'}/ead/$dir/$_.xml\">EAD</a></td>";
      $tbody .= "<td><a href=\"$confHash{'CONTENT_URI'}/html/$dir/$_\">HTML</a></td>";
      $tbody .= "</tr>";
    }
  }
  
  my $body = qq#
    <h3 class="title hidden">$heading</h3>
    <table class="tab-table pure-table pure-table-bordered pure-table-striped">
      <thead>
        <tr>
          <th>Identifier</th>
          <th colspan="2" class="preview">Review</th>
        </tr>
      </thead>
      <tbody>$tbody</tbody>
    </table>
  #;
  return $body;
  
}