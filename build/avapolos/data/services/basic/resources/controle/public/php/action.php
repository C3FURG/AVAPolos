<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once("functions.php");

if (isset($_GET['action'])) {
	#echo $_GET['action'];
	switch ($_GET['action']) {
		case 'download_stop_educapes':
			echo "Parando download do eduCAPES.";
			system("echo 'download_stop educapes' > ../../service/pipe");
			echo "Sinal enviado para o serviço.";
			break;

		case 'download_start_educapes':
			echo "Iniciando download do eduCAPES.";
			system("echo 'download_start educapes' > ../../service/pipe");
			echo "Sinal enviado para o serviço.";
			break;

		case 'start':
			echo "Iniciando execução da solução";
			system("echo 'start' > ../../service/pipe");
			echo "Sinal enviado para o serviço.";
			break;

		case 'stop':
			echo "Parando execução da solução";
			system("echo 'stop' > ../../service/pipe");
			echo "Sinal enviado para o serviço.";
			break;

		case 'access_mode_ip':
			echo "Configurando solução para ser acessada por IP";
			system("echo 'access_mode ip' > ../../service/pipe");
			echo "Sinal enviado para o serviço.";
			break;

		case 'access_mode_name':
			echo "Configurando solução para ser acessada por nomes";
			system("echo 'access_mode name' > ../../service/pipe");
			echo "Sinal enviado para o serviço.";
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
