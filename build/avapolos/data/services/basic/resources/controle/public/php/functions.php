<?php

require_once("config.php");

if ($debug) {
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
}

function return_progress_educapes(){
  $data=@file_get_contents("../../educapes/download/wget-log");
  if ($data == FALSE) {
    $data="Não foi possível encontrar o arquivo de log do download do eduCAPES.";
  }
  echo $data;
}

function return_service_log(){
  $data=@file_get_contents("../../log/service.log");
  if ($data == FALSE) {
    $data="Não foi possível encontrar o arquivo de log do serviço.";
  }

  if ($data == "") {
    echo "Nenhum dado.";
  } else {
    echo $data;
  }
}


?>
