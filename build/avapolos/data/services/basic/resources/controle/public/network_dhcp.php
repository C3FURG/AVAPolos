<?php
require_once("config.php");
if ($CFG->debug) {
  ini_set('display_errors', 1);
  ini_set('display_startup_errors', 1);
  error_reporting(E_ALL);
}
?>

<div class="well">
  <div class="row">
    <div class="col">
      <label class="switch">
        <input type="checkbox">
        <span class="slider"></span>
      </label>
      <b class="text-center">Habilitar servidor DHCP</b>
    </div>
  </div>
  <div class="row-fluid">
    <label class="switch">
      <input type="checkbox">
      <span class="slider"></span>
    </label>
    <label for="manualConfigFile">Configuração avançada</label>
    <textarea id="manualConfigFile" class="form-control" style="width: 100%;"></textarea>
  </div>
</div>

<div class="modal fade" id="confirm-submit" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                Confirme os dados:
            </div>
            <div class="modal-body">
                Você tem certeza que os dados estão corretos?

                <table class="table">
                    <tr id="modalEmailTr" hidden>
                        <th>E-Mail</th>
                        <td id="modalEmail"></td>
                    </tr>
                    <tr id="modalPassTr" hidden>
                        <th>Senha</th>
                        <td id="modalPass"></td>
                    </tr>
                    <tr>
                        <th>Domínio</th>
                        <td id="modalDomain"></td>
                    </tr>
                </table>

            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancelar</button>
                <button id="submit" type="submit" class="bg-dark btn btn-primary">Salvar</button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">

  $(document).ready(function(){

		debug = <?php echo ($CFG->debug) ? 'true' : 'false'; ?>;

    $(".painel_btn").click(function(e) {
      run($(this).attr('id'), debug);
    })

    function togglePasswordVisibility() {
      var x = document.getElementById("passwordInput");
      if (x.type === "password") {
        x.type = "text";
      } else {
        x.type = "password";
      }
    }
    function toggleVisibility(elementId) {
      if ($(elementId).attr("hidden")) {
        $(elementId).attr("hidden", false)
      } else $(elementId).attr("hidden", true)
    }

    $('#hideForm').on('click', function() {
      toggleVisibility("#emailInputDiv")
      toggleVisibility("#passwordInputDiv")
      toggleVisibility("#modalEmailTr")
      toggleVisibility("#modalPassTr")
      toggleVisibility("#noipHelpText")
    });
    $('#submitBtn').click(function() {
      $('#modalEmail').text($('#emailInput').val());
      $('#modalPass').text($('#passwordInput').val());
      $('#modalDomain').text($('#domainInput').val());
    });
    $('#submit').click(function() {
      data = {};
      if (debug) {
        data.action = "test";
      } else {
        data.action = "setup_dns";
      }
      data.email = "null";
      data.pass = "null";
      data.domain = $('#domainInput').val();

      if (!$("#emailInputDiv").attr("hidden")) {
        data.email = $('#emailInput').val()
        data.pass = $('#passwordInput').val()
      }

      $.post("php/action.php", data);
      $('#confirm-submit').modal('toggle');
      sweet_alert('http://controle.' + data.domain + '/php/check.php', 'http://controle.' + data.domain)

      setTimeout(function () {
        console.log("http://controle." + data.domain + "/?page=dns.php");
        window.location.href = "http://controle." + data.domain + "/?page=dns.php";
      }, 100000);
    });

  });

</script>
