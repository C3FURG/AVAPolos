<?php
require_once("config.php");
if ($CFG->debug) {
  ini_set('display_errors', 1);
  ini_set('display_startup_errors', 1);
  error_reporting(E_ALL);
}
?>

<div class="row well">
  <div class="col-md">
    <p class="text-center"><b>Servidor DHCP próprio</b></p>
    <div class="text-center">
      <button class="bg-dark btn btn-primary painel_btn" id="enable_dhcp">Habilitar</button>
      <button class="bg-dark btn btn-primary painel_btn" id="disable_dhcp">Desabilitar</button>
    </div>
  </div>
</div>

  <!-- <div class="row-fluid">
    <label class="switch">
      <input type="checkbox" id="hideAdvanced">
      <span class="slider"></span>
    </label>
    <label for="manualConfigFile">Enviar arquivo de configuração do isc-dhcpd</label>
    <textarea id="manualConfigFile" class="form-control" style="width: 100%;" hidden></textarea>
  </div> -->

<script type="text/javascript">

  $(document).ready(function(){

		debug = <?php echo ($CFG->debug) ? 'true' : 'false'; ?>;

    $(".painel_btn").click(function(e) {
      run($(this).attr('id'), debug);
    })

  });

</script>
