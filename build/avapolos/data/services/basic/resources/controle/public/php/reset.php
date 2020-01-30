<?php
session_start();

if(!$_SESSION['login']){ //caso não esteja logado, redireciona para o login
	header('Location: ../login.php');
}
require_once('../config.php');
$DB = pg_connect("host=$CFG->dbhost port=$CFG->dbport dbname=$CFG->dbname user=$CFG->dbuser password=$CFG->dbpass") or die('connection failed');
pg_query($DB, "DELETE FROM public.controle_login;");
echo "Nova senha: Admin@123\r\n";
$pass=md5('Admin@123');
pg_query($DB, "INSERT INTO public.controle_login (login, password) VALUES ('admin', '$pass');");

?>
