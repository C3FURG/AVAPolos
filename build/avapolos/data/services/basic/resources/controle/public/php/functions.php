<?php
require_once("../config.php");

if ($CFG->debug) {
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
}

function startsWith($haystack, $needle)
{
     $length = strlen($needle);
     return (substr($haystack, 0, $length) === $needle);
}

function endsWith($haystack, $needle)
{
    $length = strlen($needle);
    if ($length == 0) {
        return true;
    }

    return (substr($haystack, -$length) === $needle);
}

function returnLog($logName) {
	$handle = @fopen("../../log/" . $logName, "r");
	if ($handle) {
		while (($line = fgets($handle)) !== false) {
			echo $line."\r";
		}
		fclose($handle);
	} else {
		echo "Não foi possível encontrar o arquivo de log especificado.\r\n";
	}
}

function return_progress_educapes() {
	$handle = @fopen("../../educapes/download/wget-log", "r");
	if ($handle) {
		while (($line = fgets($handle)) !== false) {
			echo $line."\r";
		}
		fclose($handle);
	} else {
		echo "Não foi possível encontrar o arquivo de log especificado.\r\n";
	}
}
?>
