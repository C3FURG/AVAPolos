<?php
unset($CFG);
global $CFG;
$CFG = new stdClass();

//$CFG->debug     = false;
$CFG->debug     = true;
$CFG->dbhost    = 'db_controle';
$CFG->dbport    = 5432;
$CFG->dbname    = 'moodle';
$CFG->dbuser    = 'moodle';
$CFG->dbpass    = '';

?>
