<?php
require_once("config.php");

if ($CFG->debug) {
  ini_set('display_errors', 1);
  ini_set('display_startup_errors', 1);
  error_reporting(E_ALL);
}
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
          <button class="bg-dark btn btn-primary painel_btn" id="restart">Reiniciar</button>
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

</style>
<script type="text/javascript">
  $(document).ready(function(){

    debug = <?php echo ($CFG->debug) ? 'true' : 'false'; ?>;

    $(".painel_btn").click(function(e) {
      run($(this).attr('id'), debug);
    })

  });

</script>
