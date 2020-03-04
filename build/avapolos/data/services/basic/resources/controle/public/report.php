<?php
  //$DB = pg_connect("host=db_controle port=5432 dbname=moodle user=moodle password=@bancoava.C4p35*&") or die('connection failed');
  require("config-control.php");
  ini_set('display_errors', 1);
  ini_set('display_startup_errors', 1);
  error_reporting(E_ALL);


  $DB = pg_connect("host=$CFG->dbhost port=$CFG->dbport dbname=$CFG->dbname user=$CFG->dbuser password=$CFG->dbpass") or die('connection failed');

  $queryRegistro = pg_query($DB, "SELECT * FROM public.controle_registro WHERE id = 1 ");

  if($queryRegistro && pg_num_rows($queryRegistro) > 0){
    $dadosRegistro = pg_fetch_array($queryRegistro);
    $emailDev = $dadosRegistro['email_dev'];
  }else{
    $emailDev = 'E-mail do suporte não cadastrado';
  }


  if(isset($_POST) && isset($_POST['submitBtn']) && $_POST['submitBtn'] != ''){
    $zip = new ZipArchive;

    //echo "logs_".date("d_m_Y")."_".date("H_i_s").".zip";
    $data = date("Y-m-d H:i:s");
    echo "data a. ".$data.'<br>';
    $dataFormatada = str_replace("-", "_", substr($data, 0, 10))."_".str_replace(":", "_", substr($data, 11));
    echo "data ".$dataFormatada;
    $nomeArquivo = "logs_".$dataFormatada.".zip";

    $filename = "./log/".$nomeArquivo;

    $logFiles = scandir("/app/log/");

    //echo var_dump($logFiles);

    if($zip->open($filename, ZipArchive::CREATE) === TRUE){
      foreach ($logFiles as $key => $value) {
        
        $localArquivo = '/app/log/'.$value;
        if(file_exists($localArquivo) && is_file($localArquivo)){
          //echo '/app/log/'.$value;
          if($zip->addFile($localArquivo, $value)){
            //echo ' - adicionado <br>';

          }else{
            //echo ' - erro <br>';
          }  
        }
        
      }

      $zip->close();


      //salva os dados no banco
      $comentario = filter_input(INPUT_POST, 'comentario-report', FILTER_SANITIZE_SPECIAL_CHARS);

      $queryInsert = pg_query($DB, "INSERT INTO public.controle_reporte (nome, local, data, comentario) VALUES ('".$nomeArquivo."','".$filename."', '".$data."', '".$comentario."')");
      if($queryInsert){


        $_SESSION['success_msg'] = "Reporte enviado com sucesso!";

        header("Location: index.php?page=report.php");
        exit();
      }
      
    }else{
      //echo "erro";
    }

    //echo var_dump(scandir("./")); 
  }  
?>

<form action="#" method="POST" enctype="multipart/form-data">
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
    <textarea class='form-control' rows="6" placeholder="Diga-nos detalhes do problema, se possível..." name='comentario-report'></textarea>
  </div>
  
  <button type="submit" name="submitBtn" id="submitBtn" value='submitBtn' class="btn btn-primary" >Enviar</button>
  <br><br>
  <?php
      if(isset($_SESSION['success_msg']) && $_SESSION['success_msg'] != ''){
  ?>
  <div class='form-group'>
      <div class="alert alert-success" role="alert">
          <span><?php echo $_SESSION['success_msg']; ?></span>
      </div>
  </div>
  <?php
          unset($_SESSION['success_msg']);
      } //end error msg
  ?>

  <?php
    $tipoInstalacao = (file_exists("/app/scripts/polo")) ? 'POLO' : 'IES'; // IES ou POLO

   // if($tipoInstalacao == "POLO"){

    $queryBusca = pg_query($DB, "SELECT * FROM public.controle_reporte ORDER BY id DESC");

    if($queryBusca && pg_num_rows($queryBusca) > 0){
      echo "

      <h5>Reports Enviados</h5>
      <div class='p-3'>
        <div class='row'>
          <table class=\"table table-hover\">
            <thead>
              <tr>
                <th scope=\"col\">Nome</th>
                <th scope=\"col\">Data</th>
                <th scope=\"col\">Comentário</th>
                <th scope=\"col\"></th>
              </tr>
            </thead>
            <tbody>";
        while($dadosBusca = pg_fetch_array($queryBusca)){
          echo "
            <tr>
              <td><a href='".$dadosBusca['local']."' download>".$dadosBusca['nome']."</a></td>
              <td>".date_format(date_create($dadosBusca['data']), "d/m/Y - H:i:s")."</td>
              <td>".$dadosBusca['comentario']."</td>
              <td><a href='".$dadosBusca['local']."' download><i class=\"fas fa-file-download\"></i> Baixar </a></td>
            </tr>";
        }
      echo " </tbody>
          </table>
        </div>
      </div>
      ";
    }

  ?>
  <!-- <ul class="nav nav-tabs">
    <li class="nav-item">
      <a class="nav-link active" href="#">Reports Enviados</a>
    </li>
    <li class="nav-item">
      <a class="nav-link " href="#">Link</a>
    </li>
  </ul> -->
  

  <?php
   // } //fim if tipo instalação
  ?>
</form>
