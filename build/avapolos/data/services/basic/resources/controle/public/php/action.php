<?php

require_once("config.php");

if ($debug) {
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
}

require_once("functions.php");

if (isset($_GET['action'])) {
	#echo $_GET['action'];
	switch ($_GET['action']) {
		case 'educapes_download_stop':
			system("echo 'educapes_download_stop' > ../../service/pipe", $retVal);
			echo $retVal;
			break;

		case 'educapes_download_start':
			system("echo 'educapes_download_start' > ../../service/pipe", $retVal);
			echo $retVal;
			break;

		case 'start':
			system("echo 'start' > ../../service/pipe", $retVal);
			echo $retVal;
			break;

		case 'stop':
			system("echo 'stop' > ../../service/pipe", $retVal);
			echo $retVal;
			break;

		case 'access_mode_ip':
			system("echo 'access_mode ip' > ../../service/pipe", $retVal);
			echo $retVal;
			break;

		case 'access_mode_name':
			system("echo 'access_mode name' > ../../service/pipe", $retVal);
			echo $retVal;
			break;

		case 'setup_noip':
			if (!empty($_POST['email']) && (!empty($_POST['pass'])) && (!empty($_POST['domain'])) ) {
				system("echo 'setup_noip " . $_POST['email'] . " " . $_POST['pass'] . " " . $_POST['domain'] . "' > ../../service/pipe;", $retVal);
				echo $retVal;
			} else {
				echo 666;
			}
			break;

		case 'get_progress':
			if (isset($_GET['subject'])) {
				switch ($_GET['subject']) {
					case 'educapes_download':
						echo return_progress_educapes();
						break;
					case 'service':
						echo return_service_log();
						break;

					default:
						echo "Nenhum objeto válido especificado.";
						break;
				}
			} else {
				echo "Nenhum objeto especificado.";
			}
			#echo return_progress_educapes();
			break;

		default:
			echo "Ação inválida especificada.";
			break;
	}
	#sleep(1000);
} else {
	echo "Nenhum dado foi fornecido";
}
