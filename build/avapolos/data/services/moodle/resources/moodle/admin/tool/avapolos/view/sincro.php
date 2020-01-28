<?php
set_time_limit(0);


require_once(dirname(__FILE__) . '/../../../../config.php');
require_once($CFG->libdir.'/adminlib.php');
require_once('simpleform.php'); // require do arquivo de formulario
require_once('functions.php'); // require do arquivo de funções
admin_externalpage_setup('tool_avapolos'); // Bloco lateral direito
echo $OUTPUT->header(); // header da página OBLIGATORY
define("IP", "avapolos");
define("PORT", 22);

// Instantiate simplehtml_form
$exportform = new export_form();
$importform = new import_form();

require_once("$CFG->libdir/filestorage/file_storage.php");
$file_storage = new file_storage();

// Form processing and displaying is done here
if ($exportform->is_cancelled() || $importform->is_cancelled()) {
  // Handle form cancel operation, if cancel button is present on form
}
else if ($fromform = $exportform->get_data()) {
  //
  $choice = [];
  foreach ($fromform as $aux) {
    $choice[] = $aux;
  }

  echo "<pre>";
  $file_storage->cron(true);
  echo "</pre>";

  $ssh = new Connect_SSH(IP, PORT, "avapolos","avapolos");
  $ssh->create_ssh_connection();
  $ssh->exec_ssh_export($choice[0] == "online",$choice[1]);
  //

  if($choice[0] == "offline"){
    try{
      echo "Aguardando exportação...";
      echo "
      <style>
      	.swal2-title{
      		display: block !important;
      	}
      </style>
      <script src='sweetalert2.all.min.js'></script>
      <script>
        let timerInterval = Swal.fire({
          title: '<img style=\"margin-top: 30px; height: 80px;\" src=\"logoAVA2.png\" /><br /><br/><h4>Aguarde exportação em andamento!</h4>'+
          '<img src=\"Eclipse-1s-200px (2).gif\" style=\"height: 40px;\">',
          html:
			'',
          allowOutsideClick: false,
          showCloseButton: false,
		  showCancelButton: false,
		  showConfirmButton: false,
          onBeforeOpen: () => {
           
            let temporizadorAjax = setInterval(()=>{
              var request = new XMLHttpRequest();
                request.onreadystatechange = function() {
                  if(request.readyState === 4) {
                    if(request.status === 200) {
                      let response = request.responseText;
                      console.log(response);
                      if(response != false){
                        Swal.close();
                        clearInterval(temporizadorAjax);
                        if(response==-1){
                           Swal.fire({
                             type: 'error',
                             title: 'Oops...',
                             text: 'Ocorreu um erro na exportação. ',
                             footer: '<a href=\"mailto:ti.c3@furg.br\"> Clique aqui para contatar os desenvolvedores AVA-Polos.</a>',
                             showConfirmButton: false,
                           })
                        }else{
                           Swal.fire({
                             type: 'html',
                             title: '<img style=\"margin-top: 30px; height: 80px;\" src=\"logoAVA2.png\" /><br /><br/><h4 style=\"color: #5F6A44;\">Exportação realizada com sucesso!</h4>'+
                             '<img src=\"okay-1.1s-289px.png\" style=\"height: 60px; \">',
                   allowOutsideClick: false,
                              html:     
                              '<b><a style=\"font-size: 13pt;\" href=\"'+response+'\"><img style=\"height: 30px;\" src=\"download-1.4s-203px.png\"> Clique aqui para baixar o arquivo de exportação</a> <br /><br />'+
                              '<a style=\"font-size: 11pt; color: #626262;\" href=\"javascript:history.back()\">Clique aqui para voltar</a></b>',
                              showConfirmButton: false,
                           })

                        }
                      }else{
                        console.log('Ainda não');
                      }


                    } else {
                      console.log(request.status + ' ' + request.statusText);
                    }
                  }
                }

                request.open('Get', 'verifyFile.php');
                request.send();
            },5000);
          },
          onClose: () => {
            clearInterval(timerInterval)
          }
        })
    </script>";

    }

    catch(\Exption $e){
      echo $e;
    }
  }
  else if($choice[0] == "online"){
        try{
          //echo "Aguardando exportação e envio do arquivo...";
          echo "<script src='sweetalert2.all.min.js'></script>
<script>
let timerInterval = Swal.fire({
                        title: '<img style=\"margin-top: 30px; height: 80px;\" src=\"logoAVA2.png\" /><br /><br/><h4>Aguarde exportação em andamento!</h4>'+
					  '<img src=\"Eclipse-1s-200px (2).gif\" style=\"height: 40px;\">',
					  html:
						'',
					  allowOutsideClick: false,
					  showCloseButton: false,
					  showCancelButton: false,
					  showConfirmButton: false,
                        onBeforeOpen: () => {
                              
                              let temporizadorAjax = setInterval(()=>{
                                 var request = new XMLHttpRequest();
                                 request.onreadystatechange = function() {
                                    if(request.readyState === 4) {
                                       if(request.status === 200) {
                                          let response = request.responseText;
                                          console.log(response);
                                          if(response != false){
                                             Swal.close();
                                             clearInterval(temporizadorAjax);
                                             if(response==-1){
                                                Swal.fire({
                                                   type: 'error',
                                                   title: 'Oops...',
                                                   text: 'Ocorreu um erro na exportação. ',
                                                   footer: '<a href=\"mailto:ti.c3@furg.br\"> Clique aqui para contatar os desenvolvedores AVA-Polos.</a>',
                                                   showConfirmButton: false,
                                                })
                                             }else{
                                                Swal.fire({
                                                   type: 'html',
											     title: '<img style=\"margin-top: 30px; height: 80px;\" src=\"logoAVA2.png\" /><br /><br/><h4 style=\"color: #5F6A44;\">Exportação realizada com sucesso!</h4>'+
											     '<img src=\"okay-1.1s-289px.png\" style=\"height: 60px; \">',
									   allowOutsideClick: false,
											      html:     
											      '<b><a style=\"font-size: 13pt;\" href=\"'+response+'\"><img style=\"height: 30px;\" src=\"download-1.4s-203px.png\"> Clique aqui para baixar o arquivo de exportação</a> <br /><br />'+
											      '<a style=\"font-size: 11pt; color: #626262;\" href=\"javascript:history.back()\">Clique aqui para voltar</a></b>',
                                                   showConfirmButton: false,
                                                })
                                             }
                                          }else{
                                             console.log('Ainda não');
                                          }
                                       } else {
                                          console.log(request.status + ' ' + request.statusText);
                                       }
                                    }
                                 }
                                 request.open('Get', 'verifyFile.php');
                                 request.send();
                              },5000);
                           },
                           onClose: () => {
                              clearInterval(timerInterval)
                           }
                        })
</script>";

        }

        catch(\Exption $e){
          echo $e;
        }
  }
}

//Importação
else if($fromform = $importform->get_data()){
  $fileName = "dadosImportTemp.tar.gz";
  // salvar o arquivo no diretório
  $success = $importform->save_file('datafile', "./$fileName", true);
  if(!$success)
    exit("ERRO AO SALVAR ARQUIVO DE SINCRONIZAÇÃO (sincro.php), CONTATE O ADMINISTRADOR.");

  echo "<pre>";
  $file_storage->cron(true);
  echo "</pre>";

  try {
    $ssh = new Connect_SSH(IP, PORT, "avapolos","avapolos");
    $ssh->create_ssh_connection();
    $ssh->exec_ssh_import();
    echo "
	  <script src='sweetalert2.all.min.js'></script>
<script>
   let timerInterval = Swal.fire({
      title: 'Aguarde, sincronização em andamento.',
      html:
		'<img style=\"height: 80px;\" src=\"logoAVA2.png\" />'+
		'<br><img src=\"Eclipse-1s-200px (2).gif\" style=\"height: 65px; margin-top: 30px;\">',
      allowOutsideClick: false,
      onBeforeOpen: () => {
         
         let temporizadorAjax = setInterval(()=>{
            var request = new XMLHttpRequest();
            request.onreadystatechange = function() {
               if(request.readyState === 4) {
                  if(request.status === 200) {
                     let response = request.responseText;
                     console.log(response);
                     if(response != false){
                        Swal.close();
                        clearInterval(temporizadorAjax);
                        if(response==-1){
                           Swal.fire({
                              type: 'error',
                              title: 'Oops...',
                              text: 'Ocorreu um erro na exportação. ',
                              footer: '<a href=\"mailto:ti.c3@furg.br\"> Clique aqui para contatar os desenvolvedores AVA-Polos.</a>',
                              showConfirmButton: false,
                           })
                        }else{
                           Swal.fire({
                              allowOutsideClick: false,
                              type: 'success',
                              title: 'Importação realizada com sucesso!',
                              html: '<Swal.close(); clearInterval(temporizadorAjax);b><a href=\"javascript:history.back()\">Clique para voltar.</a></b>',
                              showConfirmButton: false,
                           })
                        }
                     }else{
                        console.log('Ainda não');
                     }


                  } else {
                     console.log(request.status + ' ' + request.statusText);
                  }
               }
            }

            request.open('Get', 'verifyFile.php');
            request.send();
         },5000);
      },
      onClose: () => {
         clearInterval(timerInterval)
      }
   })
</script>";
    }
    catch(Exception $e){
      echo $e;
    }

  }

else {
  // this branch is executed if the form is submitted but the data doesn't validate and the form should be redisplayed
  // or on the first display of the form.
  echo '
  <script src="jquery-3.4.1.min.js"></script>
  <script>
     $(document).ready(function(){

       $("#fitem_id_ipRemoto").hide();
       $("#id_offon_offline").click(function(){
            $("#fitem_id_ipRemoto").hide();
       });
       $("#id_offon_online").click(function(){
            $("#fitem_id_ipRemoto").show();
       });

       $("#mform1").on("submit", function(){
         if($("#id_offon_online").prop("checked")){
            if(!$("#id_ipRemoto").val()){
               alert("Para realizar a exportação online informe o endereço do servidor remoto.");
               return false;
            }
         }
       });
     });
  </script>
  ';
  // Set default data (if any)
  $exportform->set_data($toform);
  // displays the form
  echo "<h3>Exportar</h3>";
  $exportform->display();
  //==============================
  echo "<hr>";
  //==============================
  echo "<h3>Importar</h3>";
  // Set default data (if any)
  $importform->set_data($toform);
  // displays the form
  $importform->display();
  /*echo "
  <script src='sweetalert2.all.min.js'></script>
  <script>
    document.getElementById('mform2').onsubmit = function(event){
        let timerInterval = Swal.fire({
        title: 'Aguarde, upload do arquivo em andamento.',
        allowOutsideClick: false,
        onBeforeOpen: () => {
          Swal.showLoading()
          let temporizadorAjax = setInterval(()=>{
            var request = new XMLHttpRequest();
              request.onreadystatechange = function() {
                if(request.readyState === 4) {
                  if(request.status === 200) {
                    let response = request.responseText;
                    console.log(response);
                    if(response == true){
                      Swal.close();
                      clearInterval(temporizadorAjax);
                      Swal.fire({
                        type: 'success',
                        title: 'Importação realizada com sucesso!',
                         html: '<b><a href=\"http://localhost/moodle\">Clique para ser redirecionado.</a></b>',
                         showConfirmButton: false,
                      })
                    }else{
                      console.log('Ainda não');
                    }


                  } else {
                    console.log(request.status + ' ' + request.statusText);
                  }
                }
              }

              request.open('Get', 'verifyFile.php');
              request.send();
          },5000);
        },
        onClose: () => {
          clearInterval(timerInterval)
        }
      })
    }
  </script>";*/
}


echo $OUTPUT->footer();

// $popUp = "<script>document.querySelectorAll('#id_submitbutton')[1].addEventListener('click',(element)=>{alert('A importação pode demorar até 20 minutos ou mais. DESLIGUE O SLAVE!!!!!')});</script>";
echo $popUp;
