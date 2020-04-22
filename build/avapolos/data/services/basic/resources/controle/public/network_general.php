<?php
require_once('config.php');
?>
<style media="screen">
  .fa-question-circle {
    opacity: 0.6;
    cursor: pointer;
  }
</style>
<div class="row well">
  <div class="col-md">
    <p class="text-center"><b>Modo de acesso</b> <i class="far fa-question-circle" data-toggle="popover" data-content="Acesso do servidor por nome ou IP."></i></p>
    <div class="text-center">
      <button class="bg-dark btn btn-primary painel_btn" id="access_mode_ip">IP</button>
      <button class="bg-dark btn btn-primary painel_btn" id="access_mode_name">Nome</button>
    </div>
  </div>
</div>

<div class="well">
  <p><b>Configurações de Endereço</b></p>
  <div class="row">
    <div class="col-md">
      <div class="form-group">
        <label for="ipInput">IP</label>
        <input type="text" class="ip form-control" id="ipInput" maxlength="15" placeholder="xxx.xxx.xxx.xxx" required>
        <h6 id="ipInputError" class="d-none text-danger">Endereço IP inválido.</h6>
      </div>
    </div>
    <div class="col-md">
      <div class="form-group">
        <label for="dns1Input">DNS Primário</label>
        <input type="text" class="ip form-control" id="dns1Input" maxlength="15" placeholder="8.8.8.8" required>
        <h6 id="dns1InputError" class="d-none text-danger">Endereço IP inválido.</h6>
      </div>
    </div>
  </div>
  <div class="row">
    <div class="col-md">
      <div class="form-group">
        <label for="gwInput">Gateway</label>
        <input type="text" class="ip form-control" id="gwInput" maxlength="15" placeholder="xxx.xxx.xxx.xxx" required>
        <h6 id="gwInputError" class="d-none text-danger">Endereço IP inválido.</h6>
      </div>
    </div>
    <div class="col-md">
      <div class="form-group">
        <label for="dns2Input">DNS Secundário.</label>
        <input type="text" class="ip form-control" id="dns2Input" maxlength="15" placeholder="8.8.4.4" required>
        <h6 id="dns2InputError" class="d-none text-danger">Endereço IP inválido.</h6>
      </div>
    </div>
  </div>
    <div class="row">
      <div class="col-md-6">
        <div class="form-group">
          <label for="maskInput">Máscara de rede</label>
          <input type="text" class="ip form-control" id="maskInput" maxlength="15" placeholder="xxx.xxx.xxx.xxx" required>
          <h6 id="maskInputError" class="d-none text-danger">Endereço IP inválido.</h6>
        </div>
      </div>
    </div>
    <button id="networkSubmitBtn" type="submit" class="bg-dark btn btn-primary">Salvar</button>
  </div>
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
                    <tr>
                        <th>Gateway</th>
                        <td id="modalGw"></td>
                    </tr>
                    <tr>
                        <th>Máscara de Rede</th>
                        <td id="modalMask"></td>
                    </tr>
                    <tr>
                        <th>DNS Primário</th>
                        <td id="modalDns1"></td>
                    </tr>
                    <tr>
                        <th>DNS Secundário</th>
                        <td id="modalDns2"></td>
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

  debug = <?php echo ($CFG->debug) ? 'true' : 'false'; ?>;

  $(function () {
    $('[data-toggle="popover"]').popover()
  })

  $('#errorAlert').addClass('d-none');
  $('.ip').mask('099.099.099.099');

  $(".painel_btn").click(function(e) {
    run($(this).attr('id'), debug);
  })

  $('#networkSubmitBtn').click(function() {
    inputs = ['#ipInput', '#gwInput', '#maskInput', '#dns1Input', '#dns2Input'];
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
      $('#modalGw').text($('#gwInput').val());
      $('#modalMask').text($('#maskInput').val());
      $('#modalDns1').text($('#dns1Input').val());
      $('#modalDns2').text($('#dns2Input').val());
      $('#confirm-submit').modal('show');
    } else {
      $('#confirm-submit').modal('hide');
    }
  });

  $('#submit').click(function(){
    data = {
      action: <?php echo ($CFG->debug) ? "'test'" : "'update_network'"; ?>,
      ip: $('#ipInput').val(),
      gw: $('#gwInput').val(),
      mask: $('#maskInput').val(),
      dns1: $('#dns1Input').val(),
      dns2: $('#dns2Input').val()
    }

    $.post("php/action.php", data).done(function(data, e) {
      if (data == "badIp") {
        $('#errorAlert').removeClass('d-none');
      } else {
        $('#errorAlert').addClass('d-none');
        sweet_alert('/php/check.php')
        setTimeout(function () {
          location.reload();
        }, 60000);
      }
    });
  });
});

</script>
