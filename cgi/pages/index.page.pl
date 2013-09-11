#!/usr/bin/perl

use strict;

# load settings and configuration options
# do 'inc/readConf.pl';

# cast loaded settings and configuration into a hash
# my %confHash = createHashConf("../conf/eadpublisher.conf");

sub getBody {

  my $body = qq#
    <h2>EAD Publisher</h2>
    <p>A tool for special collections researchers to upload, transform, and publish Finding Aids</p>
    <h3 id="help">Help</h3>
    <h4>Access Report</h4>
    <p>A tool for special collections researchers to generate access report page from Finding Aids</p>
    <p>There are 3 parts in this system.</p>
    <p>The first part is the <strong>UID2DRI hash table generator</strong>. It generates the hash table for all Finding Aids. You need to call this script directly from server.</p>
    <p>The second part is the <strong>upload CSV section</strong>. To upload a CSV file:</p>
    <ul>
      <li>Please select a archive from the drop-down box</li>
      <li>Click on the browse button to select an CSV from your computer or shared drive</li>
      <li>To upload, please click on the upload button.</li>
    </ul>
    <p>The system will generate access report based on the hash table generated in the first step.</p>
    <p>The third part of the system is <strong>generate the access report</strong> when publishing. When you publish a file from EAD Publisher, the system generate the new report based on CSV file (uploaded in the second step) and the hash table (generated in the first step, plus the newly added FA).</p>
    <h4>EAD Publisher</h4>
    <p>A tool for special collections researchers to upload, transform, and publish Finding Aids</p>
    <p>There are 3 parts to this page.</p>
    <p>The first part is the <strong>upload section</strong>. To upload a file:</p>
    <ul>
      <li>Please select a archive from the drop-down box</li>
      <li>Click on the browse button to select an ead from your computer or shared drive</li>
      <li>To upload, please click on the upload button.</li>
    </ul>
    <p>The second part is the <strong>Pending section</strong></p>
    <p>The pending section is where finding aids can be previewed before they are finally made available to the public. If you are satisfied with the finding aid, please click on the publish button.</p>
    <p>The third part of the page has a <strong>listing of all currently published EADs and finding aids</strong></p>
  #;  
  
  return $body;

}

1;