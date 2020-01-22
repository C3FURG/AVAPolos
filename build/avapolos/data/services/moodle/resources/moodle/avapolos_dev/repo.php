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

require(__DIR__.'/../config.php');
require_once($CFG->libdir.'/clilib.php');
require_once($CFG->dirroot . '/repository/lib.php');
require_once($CFG->libdir . '/adminlib.php');

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


cli_writeln("Enabling filesystem repo.");
$type = new repository_type("filesystem", $arr, true);

$success = true;
if (!$repoid = $type->create()) {
    $success = false;
}

$plugin = "filesystem";
$context = context_system::instance();
$fromform = [
    "edit" => 0,
    "new" => "filesystem",
    "plugin" => "filesystem",
    "typeid" => 0,
    "contextid" => 1,
    "name" => "AVAPolos Sincronização",
    "fs_path" => "avapolos",
    "submitbutton" => "Salvar"
];

cli_writeln("Creating avapolos' online sync repo instance.");
$success = repository::static_function($plugin, 'create', $plugin, 0, $context, $fromform);


core_plugin_manager::reset_caches();
