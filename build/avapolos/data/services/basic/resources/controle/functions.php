<?php
require_once("php/config.php");
 ?>
<div class="container-fluid">
  <div class="row">
    <div class="col-sm">
      <div class="well well-sm">
        <p class="text-center">Download do eduCAPES</p>
        <div class="text-center">
          <button class="bg-dark btn btn-primary painel_btn" id="download_start_educapes">Iniciar(Resumir)</button>
          <button class="bg-dark btn btn-primary painel_btn" id="download_stop_educapes">Parar</button>
        </div>
      </div>
    </div>
    <div class="col-sm">
      <div class="well well-sm">
        <p class="text-center">Execução da solução</p>
        <div class="text-center">
          <button class="bg-dark btn btn-primary painel_btn" id="start">Iniciar</button>
          <button class="bg-dark btn btn-primary painel_btn" id="stop">Parar</button>
        </div>
      </div>
    </div>
    <div class="col-sm">
      <div class="well well-sm">
        <p class="text-center">Modo de acesso</p>
        <div class="text-center">
          <button class="bg-dark btn btn-primary painel_btn" id="access_mode_ip">IP</button>
          <button class="bg-dark btn btn-primary painel_btn" id="access_mode_name">Nomes</button>
        </div>
      </div>
    </div>
  </div>
</div>

<style media="screen">
.well {
  min-height: 20px;
  padding: 19px;
  margin-bottom: 20px;
  background-color: #f5f5f5;
  border: 1px solid #e3e3e3;
  border-radius: 4px;
}
</style>
<script type="text/javascript">
$(document).ready(function(){

  function run(string) {
    sweet_alert('/php/check.php?get')
    if (string == "stop") {
      setTimeout(function () {
        location.reload();
      }, 20000);
    }
    $.get( "php/action.php?action=<?php if ($debug) { echo 'test"'; } else echo '" + string'?>).done(function( data ) { $('#log').html(data); });
  }

  $(".painel_btn").click(function(e) {
    //alert($(this).attr('id'));
    run($(this).attr('id'));
  })

});

</script>
