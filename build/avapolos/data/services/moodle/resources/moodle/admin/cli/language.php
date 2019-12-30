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

$usage2 = "Installs a language pack.

Usage:
    # php cfg.php --lang=<packname>
    # php cfg.php [--help|-h]

Options:
    -h --help                   Print this help.
    --pack

Examples:
    # php language.php --lang=pt_br
        Installs portuguese on the server.
";

list($options, $unrecognised) = cli_get_params([
    'lang' => null,
], [
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

if ($options['lang'] !== null) {
  cli_writeln('Installing language.');
  $controller = new tool_langimport\controller();
  $controller->install_languagepacks('pt_br');
  cli_writeln('Done.');
} else {
  cli_writeln('Current language: ' . get_config['lang']);
}
