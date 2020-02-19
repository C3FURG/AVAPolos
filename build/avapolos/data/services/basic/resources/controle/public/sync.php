<?php
require_once("config.php");

if ($CFG->debug) {
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
}
?>

<div class="well">
  <p><b>Configurações da Sincronização Online</b></p>
  <div class="row">
    <div class="col-md">
      <div class="form-group">
        <label for="ipInput">IP do POLO remoto.</label>
        <input type="text" class="ip form-control" id="ipInput" maxlength="15" placeholder="xxx.xxx.xxx.xxx" required>
        <h6 id="ipInputError" class="d-none text-danger">Endereço IP inválido.</h6>
      </div>
    </div>
  </div>
	<button id="SubmitBtn" type="submit" class="bg-dark btn btn-primary">Salvar</button>
</div>

<div class="modal fade" id="confirm-submit" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                Confirme os dados:
            </div>
            <div class="modal-body">
              Você tem certeza de que os dados estão corretos?
                <table class="table">
                    <tr>
                        <th>IP</th>
                        <td id="modalIp"></td>
                    </tr>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-success" data-dismiss="modal" id="submit">Enviar</button>
            </div>
        </div>
    </div>
</div>

<div class="alert alert-danger" id="errorAlert" role="alert">
  Um erro ocorreu!
</div>

<script type="text/javascript">

$(document).ready(function(){
  $('#errorAlert').addClass('d-none');
  $('.ip').mask('099.099.099.099');

  //https://stackoverflow.com/questions/4460586/javascript-regular-expression-to-check-for-ip-addresses
  function ValidateIPaddress(ipaddress) {
    if (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(ipaddress)) {
      return (true)
    }
    return (false)
  }

  $('#SubmitBtn').click(function() {
    inputs = ['#ipInput'];
    flag = true;
    for (var i = 0; i < inputs.length; i++) {
      if (!ValidateIPaddress($(inputs[i]).val())) {
        $(inputs[i] + 'Error').removeClass('d-none');
        flag = false;
      } else {
        $(inputs[i] + 'Error').addClass('d-none');
      }
    }
    if (flag) {
      $('#modalIp').text($('#ipInput').val());
      $('#confirm-submit').modal('show');
    } else {
      $('#confirm-submit').modal('hide');
    }
  });

  $('#submit').click(function(){
    data = {
      action: <?php echo ($CFG->debug) ? "'test'" : "'update_sync_remote_ip'"; ?>,
      ip: $('#ipInput').val(),
    }

    $.post("php/action.php", data).done(function(data, e) {
      if (data == "badIp") {
        $('#errorAlert').removeClass('d-none');
      } else {
        $('#errorAlert').addClass('d-none');
        sweet_alert('/php/check.php')
      }
    });
  });
});

</script>
