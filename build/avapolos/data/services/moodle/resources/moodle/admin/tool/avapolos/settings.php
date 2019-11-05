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
 * Plugin administration pages are defined here.
 *
 * @package     tool_avapolos
 * @category    admin
 * @copyright   2018 Kevin Paulo <kevinppaulo@gmail.com>
 * @license     http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

if($hassiteconfig){
  $settings = new admin_settingpage('tool_adminSolution', 'AVAPolos Sincronização');
  $ADMIN->add('tools', $settings);
}

$ADMIN->add(
  'root',
  new admin_externalpage(
    'tool_avapolos', 'AVAPolos Sincronização',
    new moodle_url('/admin/tool/avapolos/view/sincro.php')
    )
  );
//
// if ($ADMIN->fulltree) {
//
//    // TODO: Define the plugin settings page.
//    // https://docs.moodle.org/dev/Admin_settings
// }
