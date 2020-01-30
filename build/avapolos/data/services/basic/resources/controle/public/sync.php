<?php
require_once("php/config.php");

if ($debug) {
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
}

?>

Página em desenvolvimento

<div class="form-group">
	<label for="remoteIpInput">IP do POLO remoto.</label>
	<input id="remoteIpInput" class="form-control" type="text">
</div>
