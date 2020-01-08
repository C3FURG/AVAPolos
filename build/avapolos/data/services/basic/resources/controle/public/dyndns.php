<script type="text/javascript">
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
       $('#lname').text($('#lastname').val());
       $('#fname').text($('#firstname').val());
  });

  $('#submit').click(function(){
       /* when the submit button in the modal is clicked, submit the form */
      alert('submitting');
      $('#formfield').submit();
  });


  $(document).ready(function(){
    $('[data-toggle="popover"]').popover();
  });

</script>
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

<form>
  <div class="form-group">
    <label for="emailInput">Endereço de email noip.com</label>
    <input type="email" class="form-control" id="emailInput" aria-describedby="emailHelp" placeholder="Insira o E-mail">
    <small id="emailHelp" class="form-text text-muted">E-mail que você utilizou para criar sua conta no site.</small>
  </div>
  <div class="form-group">
    <label for="password">Senha</label>
    <input type="password" class="form-control" aria-describedby="domainHelp" id="passwordInput" placeholder="Insira a Senha">
    <small id="passwordHelp" class="form-text text-muted">Senha que você utilizou para criar sua conta no site.</small>
    <input type="checkbox" onclick="togglePasswordVisibility()"> Mostrar Senha
  </div>
  <div class="form-group">
    <label for="domainInput">Domínio cadastrado</label>
    <input type="text" class="form-control" id="domainInput" aria-describedby="domainHelp" placeholder="Insira o domínio">
    <small id="domainHelp" class="form-text text-muted">Domínio que você criou para seu POLO EAD.</small>
  </div>
  <button type="button" id="submitBtn" class="btn btn-primary" data-toggle="popover" title="Em desenvolvimento" data-content="Funcionalidade em desenvolvimento, botão desativado.">Enviar</button>
</form>
