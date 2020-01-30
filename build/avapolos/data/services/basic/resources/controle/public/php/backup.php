<?php
session_start();

if(!$_SESSION['login']){ //caso não esteja logado, redireciona para o login
	header('Location: ../login.php');
}

require_once("../config.php");
require_once("functions.php");

$uploadDir = '/app/public/backups';
$quarantineDir = '/app/public/quarantine';

if ($CFG->debug) {
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
}

if (isset($_GET['restore'])) {
	$cmd="echo 'restore " . escapeshellcmd($_GET['restore']) . "' > ../../service/pipe";
	system($cmd, $retVal);
	echo $retVal;
} elseif (isset($_GET['delete'])) {
	unlink($_GET['delete']);
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
		if (isset($_GET['service'])) {
			$cmd .= "--service " . escapeshellcmd($_GET['service']);
		}
		$cmd .= "' > ../../service/pipe";
		system($cmd, $retVal);
		echo $retVal;
}

?>
