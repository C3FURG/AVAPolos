<form role="form" id="formfield" action="#" method="post">
  <div class="form-group mb-5">
    <label for="password"><b>Enviar reporte para os desenvolvedores</b></label><br>
    <input type="checkbox" name='email-dev'> report_avapolos@furg.br
    <small id="passwordHelp" class="form-text text-muted">Caso deseje enviar informações aos desenvolvedores da plataforma, marque essa opção</small>
    
  </div>
  <div class="form-group mb-5">
    <label for="password"><b>Enviar reporte para instituição responsável</b></label>
    <small id="passwordHelp" class="form-text text-muted"></small>
    <input type="checkbox" name='email-suporte-ies' checked disabled> ies@instituicao.br
    <hr>
  </div>
  
  <div class="form-group">
    <label for="password"><b>Adicionar comentário</b></label>
    <textarea class='form-control' rows="6" placeholder="Diga-nos detalhes do problema, se possível..."></textarea>
  </div>
  
  <button type="button" name="btn" id="submitBtn" class="btn btn-primary" data-toggle="modal" data-target="#confirm-submit">Enviar</button>
  <br><br>
</form>
<?php
  $zip = new ZipArchive;

  //echo "logs_".date("d_m_Y")."_".date("H_i_s").".zip";

  $filename = "./logs_generated/logs_".date("d_m_Y")."_".date("H_i_s").".zip";

  $logFiles = scandir("/app/log/");

  //echo var_dump($logFiles);

  if($zip->open($filename, ZipArchive::CREATE) === TRUE){
    foreach ($logFiles as $key => $value) {
      

      if(file_exists('/app/log/'.$value) && is_file('/app/log/'.$value)){
        //echo '/app/log/'.$value;
        if($zip->addFile('/app/log/'.$value, $value)){
          //echo ' - adicionado <br>';
        }else{
          //echo ' - erro <br>';
        }  
      }
      
    }

    $zip->close();
  }else{
    //echo "erro";
  }

  //echo var_dump(scandir("./"));  


  
?>