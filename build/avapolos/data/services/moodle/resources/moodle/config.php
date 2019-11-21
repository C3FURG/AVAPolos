<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->noemailever = true;

$CFG->dbtype    = 'pgsql';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'db_moodle_ies';
$CFG->dbname    = 'moodle';
$CFG->dbuser    = 'moodleuser';
$CFG->dbpass    = '@bancoava.C4p35*&';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '5432',
  'dbsocket' => '',
);

$CFG->enablewebservices = 1;
$CFG->enablemobilewebservice = 1;
#$mobileappdownloadpage = 'htt://mobileappdownloadpage';
#set_config('setuplink', $mobileappdownloadpage, 'tool_mobile');

$CFG->emailchangeconfirmation = 0;

$CFG->wwwroot   = 'http://moodle.avapolos';
$CFG->dataroot  = '/app/moodledata';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;

// @error_reporting(E_ALL | E_STRICT);
// @ini_set('display_errors', '1');
// $CFG->debug = (E_ALL | E_STRICT);
// $CFG->debugdisplay = 1;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
