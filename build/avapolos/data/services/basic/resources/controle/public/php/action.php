<?php
session_start();
function checkLogin() {
	if(!isset($_SESSION['login'])) { //caso não esteja logado
		header("HTTP/1.1 401 Unauthorized");
		header("Location: ../401.php");
		die();
	}
}
checkLogin();

require_once("../config.php");
require_once("functions.php");

if ($CFG->debug) {
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
}

if (isset($_POST['action'])) {
	switch ($_POST['action']) {
		case 'educapes_download_stop':
			system("echo 'educapes_download_stop' > ../../service/pipe", $retVal);
			echo $retVal;
			break;

		case 'educapes_download_start':
			system("echo 'educapes_download_start' > ../../service/pipe", $retVal);
			echo $retVal;
			break;

		case 'test':
			system("echo 'test' > ../../service/pipe", $retVal);
			echo $retVal;
			break;

		case 'export_all':
			system("echo 'export_all' > ../../service/pipe", $retVal);
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

		case 'update_network':
      $ip = filter_input(INPUT_POST, 'ip', FILTER_SANITIZE_SPECIAL_CHARS);
      $gw = filter_input(INPUT_POST, 'gw', FILTER_SANITIZE_SPECIAL_CHARS);
      $mask = filter_input(INPUT_POST, 'mask', FILTER_SANITIZE_SPECIAL_CHARS);
      $dns1 = filter_input(INPUT_POST, 'dns1', FILTER_SANITIZE_SPECIAL_CHARS);
      $dns2 = filter_input(INPUT_POST, 'dns2', FILTER_SANITIZE_SPECIAL_CHARS);
      if ($ip != "null") {
				if (exec("echo " . $ip . " | grep -Eo '^(([0-9]{1,3})\.){3}[0-9]{1,3}$'") == "") {
					echo "badIp";
					die();
				}
			}
			$cmd = "echo 'update_network " . $ip . " " . $gw . " " . $mask ." " . $dns1 ." " . $dns2 . "' > ../../service/pipe";
			system($cmd, $retVal);
			echo $retVal;
			break;

		case 'update_sync_remote_ip':
			$ip = filter_input(INPUT_POST, 'ip', FILTER_SANITIZE_SPECIAL_CHARS);
			$cmd = "echo 'update_sync_remote_ip " . $ip . "' > ../../service/pipe";
			system($cmd, $retVal);
			echo $retVal;
			break;

		case 'enable_dhcp':
			$cmd = "echo 'enable_dhcp' > ../../service/pipe";
			system($cmd, $retVal);
			echo $retVal;
			break;

		case 'disable_dhcp':
			$cmd = "echo 'disable_dhcp' > ../../service/pipe";
			system($cmd, $retVal);
			echo $retVal;
			break;

		case 'enable_dns':
			$cmd = "echo 'enable_dns' > ../../service/pipe";
			system($cmd, $retVal);
			echo $retVal;
			break;

		case 'disable_dns':
			$cmd = "echo 'disable_dns' > ../../service/pipe";
			system($cmd, $retVal);
			echo $retVal;
			break;

		case 'access_mode_name':
			system("echo 'access_mode name' > ../../service/pipe", $retVal);
			echo $retVal;
			break;

		case 'setup_dns':
			if (!empty($_POST['email']) && (!empty($_POST['pass'])) && (!empty($_POST['domain'])) ) {
				system("echo 'setup_dns " . $_POST['email'] . " " . $_POST['pass'] . " " . $_POST['domain'] . "' > ../../service/pipe;", $retVal);
				echo $retVal;
			} else {
				echo 666;
			}
			break;

		case 'get_log':
			if (isset($_POST['subject'])) {
				switch ($_POST['subject']) {
					case 'educapes_download':
						echo return_progress_educapes();
						break;
					case 'service':
						echo returnLog("service.log");
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
