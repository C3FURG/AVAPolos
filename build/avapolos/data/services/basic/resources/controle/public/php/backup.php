<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if (isset($_GET['delete'])) {
	if (file_exists($_GET['delete'])) {
		unlink($_GET['delete']);
		touch('../../service/done');
	} else {
		echo "false";
	}
	die;
}

if (isset($_GET['restore'])) {
	if (file_exists($_GET['restore'])) {
		$command = "echo 'restore " . $_GET['restore'] . "' > ../../service/pipe";
		system($command);
		echo "true";
	} else {
		echo "false";
	}
	die;
}

//Runs as default.

$command="backup";

if (isset($_GET['service'])) {
	if ($_GET['specific_service'] == "on") {
		$command = $command . " --service " . $_GET['service'];
		//echo "Realizando backup do serviço: " . $_GET['service'] . "\r\n";
	}
}

$command = "echo '" . $command . "' > ../../service/pipe";

echo "true";

system($command);
