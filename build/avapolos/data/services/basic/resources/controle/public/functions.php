<?php
require_once("php/config.php");
require_once("php/functions.php");

$found=false;
foreach (scandir('avapolos_clone') as $file) {
  if  (!$found && $file != '.' && $file != '..' && endsWith($file, '.tar.gz') && system('file /app/public/avapolos_clone/' . $file . " | grep -o 'POSIX shell script'") != "") {
    $found=true;
    $clone_installer_file = 'avapolos_clone/' . $file;
  }
}



 ?>
<div class="container-fluid">
  <div class="row">
    <div class="col-sm">
      <div class="well well-sm">
        <p class="text-center">Download do eduCAPES</p>
        <div class="text-center">
          <button class="bg-dark btn btn-primary painel_btn" id="educapes_download_start">Iniciar(Resumir)</button>
          <button class="bg-dark btn btn-primary painel_btn" id="educapes_download_stop">Parar</button>
        </div>
      </div>
    </div>
    <div class="col-sm">
      <div class="well well-sm">
        <p class="text-center">Execução da solução</p>
        <div class="text-center">
          <button class="bg-dark btn btn-primary painel_btn" id="restart">Reiniciar</button>
          <button class="bg-dark btn btn-primary painel_btn" id="stop">Parar</button>
        </div>
      </div>
    </div>
    <div class="col-sm">
      <div class="well well-sm">
        <p class="text-center">Clonagem</p>
        <div class="text-center">
          <button class="bg-dark btn btn-primary painel_btn" id="export_all">Iniciar</button>
          <?php if ($found) { echo "<a href='" . $clone_installer_file . "'>Baixar Arquivo</a>"; } ?>
        </div>
      </div>
    </div>
  </div>
</div>

<script type="text/javascript">
$(document).ready(function(){

  function run(string) {
    sweet_alert('/php/check.php?get')
    if (string == "stop") {
      setTimeout(function () {
        location.reload();
      }, 60000);
    }
    $.get( "php/action.php?action=<?php if ($debug) { echo 'test"'; } else echo '" + string'?>);
  }

  $(".painel_btn").click(function(e) {
    //alert($(this).attr('id'));
    run($(this).attr('id'));
  })

});

</script>
