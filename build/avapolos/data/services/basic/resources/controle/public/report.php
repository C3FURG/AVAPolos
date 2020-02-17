<?php
  $DB = pg_connect("host=db_controle port=5432 dbname=moodle user=moodle password=@bancoava.C4p35*&") or die('connection failed');

  $queryRegistro = pg_query($DB, "SELECT * FROM public.controle_registro WHERE id = 1 ");

  //echo "SELECT * FROM public.avapolos_controle_login WHERE login = '".$login."' AND password = '".$password."' ";
  if($queryRegistro && pg_num_rows($queryRegistro) > 0){
    $dadosRegistro = pg_fetch_array($queryRegistro);
    $emailDev = $dadosRegistro['email_dev'];
  }else{
    $emailDev = 'E-mail do suporte não cadastrado';
  }
?>

<form role="form" id="formfield" action="#" method="post">
  <div class="form-group mb-5">
    <label for="password"><b>Enviar reporte para os desenvolvedores</b></label><br>
    <label>
      <input type="checkbox" name='email-dev'> <?php echo $emailDev; ?>
    </label>
    <small id="passwordHelp" class="form-text text-muted">Caso deseje enviar informações aos desenvolvedores da plataforma, marque essa opção</small>
    
  </div>
  <div class="form-group mb-5">
    <label for="password"><b>Enviar reporte para instituição responsável</b></label>
    <small id="passwordHelp" class="form-text text-muted"></small>
    <label>
      <input type="checkbox" name='email-suporte-ies' checked disabled> ies@instituicao.br
    </label>
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