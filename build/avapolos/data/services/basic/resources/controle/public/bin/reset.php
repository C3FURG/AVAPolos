<?php

require_once('app/public/config.php');
require_once('app/public/php/db.php');

pg_query($DB, "DELETE FROM public.controle_login;");
echo "Nova senha: Admin@123\r\n";
$pass=md5('Admin@123');
pg_query($DB, "INSERT INTO public.controle_login (login, password) VALUES ('admin', '$pass');");
$result = pg_query($DB, "SELECT * FROM public.controle_login;");
while ($row = pg_fetch_row($result)) {
  echo "Usuário: $row[1]  Hash: $row[2]\r\n";
}
echo "Senha atualizada com sucesso.\r\n";

?>
