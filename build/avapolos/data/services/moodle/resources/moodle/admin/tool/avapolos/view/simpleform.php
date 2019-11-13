<?php

  set_time_limit(0);


  //moodleform is defined in formslib.php
  require_once("$CFG->libdir/formslib.php");

  class export_form extends moodleform {
      //Add elements to form
      public function definition() {
          global $CFG;
          global $DB;

          $mform = $this->_form; // Don't forget the underscore!

          $radioarray=array();
          $radioarray[] = $mform->createElement('radio', 'offon', '', 'Gerar e Baixar Arquivo (Offline)', 'offline');
          $radioarray[] = $mform->createElement('radio', 'offon', '', 'Gerar e Enviar Arquivo (Online)', 'online');
          $mform->addGroup($radioarray, 'offonbuttons', '', array(' '), false);

          $mform->addElement('text', 'ipRemoto', "Endereço do servidor remoto"); // Add elements to your form

          $ssh = new Connect_SSH(IP, PORT, "avapolos","avapolos");
          $ssh->create_ssh_connection();
          $ip = trim($ssh->exec_ssh_getRemoteServerIP());
          $val = 'Digite o endereço';
          if($ip!="")
            $val=$ip;
          $mform->setDefault('ipRemoto', $ip);        //Default value

          $this->add_action_buttons($cancel=false,"Exportar");



      }
      //Custom validation should be added here
      function validation($data, $files) {
          return array();
      }
  }

  class import_form extends moodleform {
      //Add elements to form
      public function definition() {
          global $CFG;
          global $DB;

          $mform = $this->_form; // Don't forget the underscore!

          //filepicker para upload do arquivo
          $mform->addElement('filepicker', 'datafile', get_string('file'), null, array('maxbytes' => 0, 'maxfiles' => 1, 'accepted_types' => 'gz'));
          // $mform->addElement('filemanager', 'attachments', get_string('attachment', 'moodle'), null, array('subdirs' => 0, 'maxbytes' => 10485760, 'areamaxbytes' => 10485760, 'maxfiles' => 10, 'accepted_types' => '*', 'return_types'=> FILE_INTERNAL | FILE_EXTERNAL));
          $mform->addRule('datafile', 'Selecione um arquivo de dados válido.', 'required');
          $this->add_action_buttons($cancel=false,"Importar");
      }
      //Custom validation should be added here
      function validation($data, $files) {
          return array();
      }
  }
