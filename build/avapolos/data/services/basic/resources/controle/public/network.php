<?php
require_once('config.php');
?>

<div class="row well">
  <div class="col-md">
    <p class="text-center"><b>Modo de acesso</b></p>
    <div class="text-center">
      <button class="bg-dark btn btn-primary painel_btn" id="access_mode_ip">IP</button>
      <button class="bg-dark btn btn-primary painel_btn" id="access_mode_name">Nome</button>
    </div>
  </div>
  <div class="col-md">
    <p class="text-center"><b>DHCP</b></p>
    <div class="text-center">
      <button class="bg-dark btn btn-primary painel_btn" id="enable_dhcp">Sim</button>
      <button class="bg-dark btn btn-primary painel_btn" id="disable_dhcp">Não</button>
    </div>
  </div>
</div>

<div class="well">
  <p><b>Configurações de IP</b></p>
  <div class="row">
    <div class="col-md">
      <div class="form-group">
        <label for="ipInput">IP</label>
        <input type="text" class="ip form-control" id="ipInput" maxlength="15" required>
        <h6 id="ipInputError" class="d-none text-danger">Endereço IP inválido.</h6>
      </div>
    </div>
    <div class="col-md">
      <div class="form-group">
        <label for="ipInput">IP</label>
        <input type="text" class="ip form-control" id="ipInput" maxlength="15" required>
        <h6 id="ipInputError" class="d-none text-danger">Endereço IP inválido.</h6>
      </div>
    </div>
  </div>
  <div class="row">
    <div class="col-md">
      <div class="form-group">
        <label for="ipInput">IP</label>
        <input type="text" class="ip form-control" id="ipInput" maxlength="15" required>
        <h6 id="ipInputError" class="d-none text-danger">Endereço IP inválido.</h6>
      </div>
    </div>
    <div class="col-md">
      <div class="form-group">
        <label for="ipInput">IP</label>
        <input type="text" class="ip form-control" id="ipInput" maxlength="15" required>
        <h6 id="ipInputError" class="d-none text-danger">Endereço IP inválido.</h6>
      </div>
    </div>
  </div>
  <button id="networkSubmitBtn" type="submit" class="bg-dark btn btn-primary">Salvar</button>
</div>

<script type="text/javascript">
$(document).ready(function(){

  $('.ip').mask('099.099.099.099');

  function run(string) {
    sweet_alert('/php/check.php?get')
    if (string == "stop") {
      setTimeout(function () {
        location.reload();
      }, 60000);
    }
    $.get("php/action.php?action=<?php echo ($CFG->debug) ? "test" : "string"; ?>");
  }

  $(".painel_btn").click(function(e) {
    //alert($(this).attr('id'));
    run($(this).attr('id'));
  })

  $("#networkSubmitBtn").click(function(e) {
    debug = <?php echo ($CFG->debug) ? "true" : "false";?>;
    data = {};
    if (debug) {
      data.action="test";
    } else {
      data.action = "update_network";
      data.dhcp = ($('#dhcpCheck').is(':checked')) ? true : false;
      if ($('#ipInput').val()) {
        data.ip = $('#ipInput').val();
      }
    }

    $.get("php/action.php", data).done(function(data, e) {
      if (data == "badIp") {
        $('#ipInputError').removeClass('d-none');
      } else {
        sweet_alert('/php/check.php?get')
        $('#ipInputError').addClass('d-none');
      }
    });
  });
});
</script>
