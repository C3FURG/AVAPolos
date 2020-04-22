<?php
session_start();

require_once("../config.php");
require_once("functions.php");

function checkLogin() {
	if(!isset($_SESSION['login'])) { //caso não esteja logado
		header("HTTP/1.1 401 Unauthorized");
		die();
	}
}
checkLogin();

$uploadDir = '/app/public/backups';
$quarantineDir = '/app/public/quarantine';

if ($CFG->debug) {
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
}

if (isset($_POST['restore'])) {
	$cmd="echo 'restore " . escapeshellcmd($_POST['restore']) . "' > ../../service/pipe";
	system($cmd, $retVal);
	echo $retVal;
} elseif (isset($_POST['delete'])) {
	unlink($_POST['delete']);
}	elseif (isset($_FILES) && isset($_FILES['Filesbackup'])) {
	$filename=$_FILES['Filesbackup']['name'];
	if (endsWith($filename, ".tar.gz")) {
		$quarantinePath=$quarantineDir . '/' . $_FILES['Filesbackup']['name'];
		move_uploaded_file($_FILES['Filesbackup']['tmp_name'], $quarantinePath);
		$out=exec("file " . $quarantinePath . " | grep -o 'gzip compressed data'");
		if ($out != "") {
			$uploadPath=$uploadDir . '/' . $_FILES['Filesbackup']['name'];
			rename($quarantinePath, $uploadPath);
			echo 1;
		} else {
			echo -1;
		}
	} else {
		echo -1;
	}
} else {
	$cmd="echo 'backup ";
		if (isset($_POST['service'])) {
			$cmd .= "--service " . escapeshellcmd($_POST['service']);
		}
		$cmd .= "' > ../../service/pipe";
		system($cmd, $retVal);
		echo $retVal;
}

?>
