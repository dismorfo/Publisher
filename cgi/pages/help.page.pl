#!/usr/bin/perl

use strict;

sub getBody {

  my $body = qq#
    <h3>Help</h3>
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