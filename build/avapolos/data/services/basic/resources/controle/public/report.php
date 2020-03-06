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

  //salvar reporte
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

  if(isset($_POST) && isset($_POST['delReporte']) && $_POST['delReporte'] != ''){
    $idReporteDelete = (int)filter_input(INPUT_POST, 'idReporte', FILTER_SANITIZE_SPECIAL_CHARS);

    $querySelectDeleteReporte = pg_query($DB, "SELECT * FROM public.controle_reporte WHERE id = ".$idReporteDelete);

    if($querySelectDeleteReporte && pg_num_rows($querySelectDeleteReporte) > 0){
      $dadosDeleteReporte = pg_fetch_array($querySelectDeleteReporte);

      //caso os dados do reporte existam e o arquivo tenha sido excluido
      if($dadosDeleteReporte && unlink($dadosDeleteReporte['local'])){
        if(pg_query($DB, "DELETE FROM public.controle_reporte WHERE id = ".$idReporteDelete)){
          $_SESSION['success_msg'] = "Reporte removido com sucesso!";
        }else{
          $_SESSION['error_msg'] = "Erro ao excluir reporte.";
        }
      }
    }

    header("Location: index.php?page=report.php");
    exit();
  }
?>

<form action="#" method="POST" enctype="multipart/form-data">
  <!-- <div class="form-group mb-5">
    <label for="password"><b>Enviar reporte para os desenvolvedores</b></label><br>
    <label>
      <input type="checkbox" name='email-dev'> <?php echo $emailDev; ?>
    </label>
    <small id="passwordHelp" class="form-text text-muted">Caso deseje enviar informações aos desenvolvedores da plataforma, marque essa opção</small>
    
  </div> -->
  <!-- <div class="form-group mb-5">
    <label for="password"><b>Enviar reporte para instituição responsável</b></label>
    <small id="passwordHelp" class="form-text text-muted"></small>
    <label>
      <input type="checkbox" name='email-suporte-ies' checked disabled> ies@instituicao.br
    </label>
    <hr>
  </div> -->
  
  <div class="form-group">
    <label for="password"><b>Adicionar comentário</b></label>
    <textarea class='form-control' rows="6" placeholder="Diga-nos detalhes do problema, se possível..." name='comentario-report'></textarea>
  </div>
  
  <button type="submit" name="submitBtn" id="submitBtn" value='submitBtn' class="btn btn-primary bg-dark" >Enviar</button>
  <br><br>
  <?php
      //SUCCESS MESSAGE
      if(isset($_SESSION['success_msg']) && $_SESSION['success_msg'] != ''){

        echo "
          <div class='form-group'>
              <div class='alert alert-success' role='alert'>
                  <span>".$_SESSION['success_msg']."</span>
              </div>
          </div>
        ";

        unset($_SESSION['success_msg']);

      } //end error msg
  ?>
  <?php
      //ERROR MESSAGE
      if(isset($_SESSION['error_msg']) && $_SESSION['error_msg'] != ''){

        echo "
          <div class='form-group'>
              <div class='alert alert-success' role='alert'>
                  <span>".$_SESSION['error_msg']."</span>
              </div>
          </div>
        ";

        unset($_SESSION['error_msg']);

      } //end error msg
  ?>


  <?php
    $tipoInstalacao = (file_exists("/app/scripts/polo")) ? 'POLO' : 'IES'; // IES ou POLO

   //if($tipoInstalacao == "POLO"){

    $queryBusca = pg_query($DB, "SELECT * FROM public.controle_reporte ORDER BY id DESC");

    if($queryBusca && pg_num_rows($queryBusca) > 0){
      echo "

        <h5>Reports Enviados</h5>
        <div class='p-3'>
          <style>
            .row-table > div{
              width: 100%;
            }
          </style>
          <div class='row row-table'>
            <table style='width: 100%;' id='table-reportes' class=\"table table-hover\">
              <thead>
                <tr>
                  <th scope=\"col\">Nome</th>
                  <th scope=\"col\">Data</th>
                  <th scope=\"col\">Comentário</th>
                  <th scope=\"col\"></th>
                  <th scope=\"col\"></th>
                </tr>
              </thead>
              <tbody>";
          while($dadosBusca = pg_fetch_array($queryBusca)){
            $comentarioAux = (strlen($dadosBusca['comentario']) <= 100) ? $dadosBusca['comentario'] : substr($dadosBusca['comentario'], 0, 100).'...';

            echo "
              <tr>
                <td><a href='".$dadosBusca['local']."' download>".$dadosBusca['nome']."</a></td>
                <td>".date_format(date_create($dadosBusca['data']), "d/m/Y - H:i:s")."</td>
                <td>".$comentarioAux." <a href='#' data-toggle='modal' data-target='#modalCommentReport".$dadosBusca['id']."'><i class=\"far fa-comment-dots\"></i></a></td>
                <td><a href='".$dadosBusca['local']."' download><i class=\"fas fa-file-download\"></i> Baixar </a></td>
                <td><a style='color: red;' href='#' data-toggle='modal' data-target='#modalDeleteReport".$dadosBusca['id']."' ><i class=\"fas fa-trash-alt\"></i> Excluir </a></td>
              </tr>";
          }
        echo " </tbody>
            </table>
          </div>
        </div>
        ";

        // modais comentarios
        $queryBuscaModais = pg_query($DB, "SELECT * FROM public.controle_reporte ORDER BY id DESC");
        while($dadosBuscaModal = pg_fetch_array($queryBuscaModais)){
          echo "
            <!-- Modal Comment -->
            <div class='modal fade' id='modalCommentReport".$dadosBuscaModal['id']."' tabindex='-1' role='dialog' aria-labelledby='' aria-hidden='true'>
              <div class='modal-dialog modal-dialog-centered modal-lg' role='document'>
                <div class='modal-content'>
                  <div class='modal-header'>
                    <h5 class='modal-title'>Comentáro ".$dadosBuscaModal['nome']."</h5>
                    <button type='button' class='close' data-dismiss='modal' aria-label='Close'>
                      <span aria-hidden='true'>&times;</span>
                    </button>
                  </div>
                  <div class='modal-body'>
                    ".$dadosBuscaModal['comentario']."
                  </div>
                </div>
              </div>
            </div>

            <!-- Modal Delete -->
            <div class='modal fade' id='modalDeleteReport".$dadosBuscaModal['id']."' tabindex='-1' role='dialog' aria-labelledby='' aria-hidden='true'>
              <div class='modal-dialog modal-dialog-centered modal-lg' role='document'>
                <div class='modal-content'>
                  <div class='modal-header'>
                    <h5 class='modal-title'>Deletar reporte</h5>
                    <button type='button' class='close' data-dismiss='modal' aria-label='Close'>
                      <span aria-hidden='true'>&times;</span>
                    </button>
                  </div>
                  <div class='modal-body'>
                    Tem certeza que deseja deletar o reporte: <b>".$dadosBuscaModal['nome']."</b> ?
                  </div>
                  <div class='modal-footer'>
                    <button type='button' class='btn btn-secondary' data-dismiss='modal'>Não</button>
                    <form method='POST' action='#'>
                      <input type='hidden' name='idReporte' value='".$dadosBuscaModal['id']."'>
                      <button type='submit' class='btn btn-primary bg-dark' name='delReporte' value='delReporte'>Sim</button>
                    </form>
                  </div>
                </div>
              </div>
            </div>
          ";
        }

      }
    //} //fim if tipo instalação
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
   // 
  ?>
</form>
<link rel="stylesheet" type="text/css" href="DataTables/datatables.min.css"/>
 
<script type="text/javascript" src="DataTables/datatables.min.js"></script>

<script type="text/javascript">
  $(document).ready(function(){
    $('#table-reportes').DataTable( {
        "language": {
          "decimal":        "",
          "emptyTable":     "Sem dados disponíveis na tabela",
          "info":           "Mostrando _START_ até _END_ de _TOTAL_ entradas",
          "infoEmpty":      "Mostrando 0 até 0 de 0 entradas",
          "infoFiltered":   "(filtrado de _MAX_ total de entradas)",
          "infoPostFix":    "",
          "thousands":      ",",
          "lengthMenu":     "Mostrando _MENU_ entradas",
          "loadingRecords": "Carregando...",
          "processing":     "Processando...",
          "search":         "Busca:",
          "zeroRecords":    "Resultados não encontrados",
          "paginate": {
              "first":      "Primeira",
              "last":       "Última",
              "next":       "Próxima",
              "previous":   "Anterior"
          },
          "aria": {
              "sortAscending":  ": ativar ordenação crescente",
              "sortDescending": ": ativar ordenação decrescente"
          }
        }
    });
  })
</script>
