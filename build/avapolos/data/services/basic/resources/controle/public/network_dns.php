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
    <p class="text-center"><b>Servidor DNS próprio</b></p>
    <div class="text-center">
      <button class="bg-dark btn btn-primary painel_btn" id="enable_dns">Habilitar</button>
      <button class="bg-dark btn btn-primary painel_btn" id="disable_dns">Desabilitar</button>
    </div>
  </div>
</div>

<form role="form" id="formfield" action="#" method="post">
  <input type="checkbox" id="hideForm"> Quero utilizar NO-IP.
  <div id="noipHelpText" class="well" hidden>
    <p>Passos para a configuração do DNS Dinâmico:</p>
    <ol>
      <li>Marque a caixa "Quero utilizar NO-IP."</li>
      <li>Contate a equipe de TI do seu POLO para liberar o acesso externo ao servidor do POLO na porta 80.</li>
      <li>Acesse o site <a href="https://noip.com/pt-BR">aqui</a>, em seguida, crie uma conta.</li>
      <li>Crie um domínio para seu polo EAD.</li>
      <li>Insira com cuidado todos os dados necessários no formulário abaixo.</li>
      <li>Clique em enviar.</li>
    </ol>
  </div>
  <div class="form-group" id="emailInputDiv" hidden>
    <label for="emailInput">Endereço de email noip.com</label>
    <input type="email" class="form-control" id="emailInput" aria-describedby="emailHelp" placeholder="Insira o E-mail" required>
    <small id="emailHelp" class="form-text text-muted">E-mail que você utilizou para criar sua conta no site.</small>
  </div>
  <div class="form-group" id="passwordInputDiv" hidden>
    <label for="password">Senha</label>
    <input type="password" class="form-control" aria-describedby="domainHelp" id="passwordInput" placeholder="Insira a Senha" required>
    <small id="passwordHelp" class="form-text text-muted">Senha que você utilizou para criar sua conta no site.</small>
    <input type="checkbox" onclick="togglePasswordVisibility()"> Mostrar Senha
  </div>
  <div class="form-group">
    <label for="domainInput">Domínio base</label>
    <input type="text" class="form-control" id="domainInput" aria-describedby="domainHelp" placeholder="Insira o domínio" required>
    <small id="domainHelp" class="form-text text-muted">Domínio para o seu POLO EAD.</small>
  </div>
  <button type="button" name="btn" id="submitBtn" class="bg-dark btn btn-primary" data-toggle="modal" data-target="#confirm-submit">Enviar</button>
  <br><br>
</form>

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
