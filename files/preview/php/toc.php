<?php 

$coll = $_GET["collectionName"];
$faid = $_GET["findingAidId"];

$myFile = '../html/' . $coll . '/' . $faid . '/toc.xml';

$fh = fopen($myFile, 'r');

$newHTML = fread($fh, filesize($myFile));

fclose($fh);

// toc settings cookie named like COLLNAME_FAID_toc_settings

$newHTML = preg_replace('/<!DOCTYPE[^>]*>/', '', $newHTML);

if (isset($_COOKIE['faid'])) {
  $faid = $_COOKIE['faid'];

  if ( isset($_COOKIE[$faid . '_toc_settings']) ) {
    $tocSettings = $_COOKIE[$faid . '_toc_settings'];
    foreach( explode(',', $tocSettings) as $id ) {
    
      $pattern = '/id="' . $id . '" style="display:none;"/';
      $replacement = 'id="' . $id . '" style="display:block;"';
      $newHTML =  preg_replace( $pattern, $replacement, $newHTML );

      $pattern = '/<span id="' . $id . 'more" class="arrow" style="display:inline;"/';
      $replacement = '<span id="' . $id . 'more" class="arrow" style="display:none;"';
      $newHTML =  preg_replace( $pattern, $replacement, $newHTML );

      $pattern = '/<span id="' . $id . 'less" class="arrow" style="display:none;"/';
      $replacement = '<span id="' . $id . 'less" class="arrow" style="display:inline;"';
      $newHTML =  preg_replace($pattern, $replacement, $newHTML);

	}
  }
}

print $newHTML;