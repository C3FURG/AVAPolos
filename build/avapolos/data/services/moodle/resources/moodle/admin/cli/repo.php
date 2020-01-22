<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

/**
 * CLI script allowing to get and set config values.
 *
 * This is technically just a thin wrapper for {@link get_config()} and
 * {@link set_config()} functions.
 *
 * @package     core
 * @subpackage  cli
 * @copyright   2019 Rafael Souza <rsouza19796@gmail.com>
 * @license     http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

define('CLI_SCRIPT', true);

require(__DIR__.'/../../config.php');
require_once($CFG->libdir.'/clilib.php');
require_once($CFG->dirroot . '/repository/lib.php');
require_once($CFG->libdir . '/adminlib.php');

$usage2 = "Adds a filesystem repo for AVAPolos' online sync.

Usage:
    # php repo.php
";

list($options, $unrecognised) = cli_get_params([
    'h' => 'help'
]);

if ($unrecognised) {
    $unrecognised = implode(PHP_EOL.'  ', $unrecognised);
    cli_error(get_string('cliunknowoption', 'core_admin', $unrecognised));
}

if ($options['help']) {
    cli_writeln($usage);
    exit(2);
}

$arr = [
    "action" => "newon",
    "repos" => "filesystem",
#    "enablecourseinstances" => 0,
#    "enableuserinstances" => 0,
    "submitbutton" => "Salvar"
];

#var_dump((array)$arr);
#var_dump($plugin);
#var_dump($visible);

#$type = new repository_type("filesystem", $arr, true);

$success = true;
#if (!$repoid = $type->create()) {
#    $success = false;
#}

$plugin = "filesystem";
$context = context_system::instance();
$fromform = [
    "test" => "a"
];

$success = repository::static_function($plugin, 'create', $plugin, 0, $context, $fromform);



core_plugin_manager::reset_caches();
