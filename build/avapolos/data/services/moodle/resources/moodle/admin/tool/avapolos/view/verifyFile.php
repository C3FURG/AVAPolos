<?php

$line = `ls | grep syncFinalizada | wc -l`;

if($line==1){
  $filename = `cat syncFinalizada`;
  unlink(getcwd()."/syncFinalizada");
  echo $filename; //Arquivo já chegou!
}else{
  echo false;//Ainda não chegou
}
?>
