<?php
require_once("../config.php");

if ($CFG->debug) {
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
}

if (file_exists('../../service/done')) {
	echo "true";
	unlink('../../service/done');
} else {
	echo "false";
}

?>
