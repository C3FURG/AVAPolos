<div class="jumbotron">
  <p>Passos para a configuração do DNS Dinâmico:</p>
  <ol>
    <li>Contate a equipe de TI do seu POLO para liberar o acesso externo ao servidor do POLO na porta 80.</li>
    <li>Acesse o site <a href="https://noip.com/pt-BR">aqui</a>, em seguida, crie uma conta.</li>
    <li>Crie um domínio para seu polo EAD.</li>
    <li>Insira com cuidado todos os dados necessários no formulário abaixo.</li>
    <li>Clique em enviar.</li>
  </ol>
</div>

<form role="form" id="formfield" action="#" method="post">
  <div class="form-group">
    <label for="emailInput">Endereço de email noip.com</label>
    <input type="email" class="form-control" id="emailInput" aria-describedby="emailHelp" placeholder="Insira o E-mail" required>
    <small id="emailHelp" class="form-text text-muted">E-mail que você utilizou para criar sua conta no site.</small>
  </div>
  <div class="form-group">
    <label for="password">Senha</label>
    <input type="password" class="form-control" aria-describedby="domainHelp" id="passwordInput" placeholder="Insira a Senha" required>
    <small id="passwordHelp" class="form-text text-muted">Senha que você utilizou para criar sua conta no site.</small>
    <input type="checkbox" onclick="togglePasswordVisibility()"> Mostrar Senha
  </div>
  <div class="form-group">
    <label for="domainInput">Domínio cadastrado</label>
    <input type="text" class="form-control" id="domainInput" aria-describedby="domainHelp" placeholder="Insira o domínio" required>
    <small id="domainHelp" class="form-text text-muted">Domínio que você criou para seu POLO EAD.</small>
  </div>
  <button type="button" name="btn" id="submitBtn" class="btn btn-primary" data-toggle="modal" data-target="#confirm-submit">Enviar</button>
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
                    <tr>
                        <th>E-Mail</th>
                        <td id="modalEmail"></td>
                    </tr>
                    <tr>
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
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                <a href="#" id="submit" class="btn btn-success success">Submit</a>
            </div>
        </div>
    </div>
</div>

<script>

function togglePasswordVisibility() {
  var x = document.getElementById("passwordInput");
  if (x.type === "password") {
    x.type = "text";
  } else {
    x.type = "password";
  }
}

$('#submitBtn').click(function() {
     /* when the button in the form, display the entered values in the modal */
     $('#modalEmail').text($('#emailInput').val());
     $('#modalPass').text($('#passwordInput').val());
     $('#modalDomain').text($('#domainInput').val());
});

$('#submit').click(function(){
     /* when the submit button in the modal is clicked, submit the form */
    alert('submitting');
    $('#formfield').submit();
});

</script>
