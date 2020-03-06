<?php
unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->debug     = false;
// $CFG->debug     = true;
$CFG->dbhost    = 'db_controle';
$CFG->dbport    = 5432;
$CFG->dbname    = 'avapolos';
$CFG->dbuser    = 'avapolos';
$CFG->dbpass    = 'bd10b9a2e191deafe6af';

if ($CFG->debug) {
  var_dump($CFG);
}
?>
