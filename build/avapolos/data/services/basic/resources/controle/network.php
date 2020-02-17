<?php
require_once('config.php');
?>

<div class="row">
  <div class="col-sm">
    <div class="well">
      <p class="text-center">Modo de acesso</p>
      <div class="text-center">
        <button class="bg-dark btn btn-primary painel_btn" id="access_mode_ip">IP</button>
        <button class="bg-dark btn btn-primary painel_btn" id="access_mode_name">Nome</button>
      </div>
    </div>
  </div>
</div>
<div class="row">
  <div class="col-sm">
    <form class="well">
      <div class="form-group form-check">
        <input type="checkbox" class="form-check-input" id="dhcpCheck">
        <label class="form-check-label" for="dhcpInput">Prover DHCP?</label>
      </div>
      <div class="form-group">
        <label for="ipInput">IP Manual</label>
        <input type="text" class="ip form-control" id="ipInput" maxlength="15">
        <h6 id="ipInputError" class="d-none text-danger">Endereço IP inválido.</h6>
      </div>
      <button id="networkSubmitBtn" type="button" class="bg-dark btn btn-primary">Salvar</button>
    </form>
  </div>
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
