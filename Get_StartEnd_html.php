<?php 
/**
* @author Saleh Bin Homoud | 2015-06-27
* @version   1.0
*/

function Get_StartEnd_html($Html, $Start, $End){
  $Html = " ".$Html;
  $ini  = strpos($Html,$Start);
  if ($ini == 0)
    return "";
  $ini += strlen($Start);
  $len  = strpos($Html,$End,$ini) - $ini;
  return substr($Html,$ini,$len);
}

$homepage = file_get_contents('https://github.com/Saleh7');
$StartEnd = Get_StartEnd_html($homepage,"<title>","</title>");
echo $StartEnd;

?>
