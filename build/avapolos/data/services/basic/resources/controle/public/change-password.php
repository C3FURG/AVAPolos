<?php
  if(isset($_POST) && isset($_POST['submitChangePass']) && $_POST['submitChangePass'] != ''){
    require("config-control.php");
      
    $DB = pg_connect("host=$CFG->dbhost port=$CFG->dbport dbname=$CFG->dbname user=$CFG->dbuser password=$CFG->dbpass") or die('connection failed');

    

    $senhaAntiga = md5(filter_input(INPUT_POST, 'senha-antiga', FILTER_SANITIZE_SPECIAL_CHARS));
    $senhaNova = md5(filter_input(INPUT_POST, 'senha-nova', FILTER_SANITIZE_SPECIAL_CHARS));
    $senhaNovaR = md5(filter_input(INPUT_POST, 'senha-nova-r', FILTER_SANITIZE_SPECIAL_CHARS));


    $queryLogin = pg_query($DB, "SELECT * FROM public.controle_login WHERE login = '".$_SESSION['login']."' AND password = '".$senhaAntiga."' ");

    //caso a senha antiga bata com a senha do usuário logado e as senhas sejam iguais
    if($queryLogin && pg_num_rows($queryLogin) > 0 && ($senhaNova == $senhaNovaR)){
      //atualiza a senha
      $queryEdit = pg_query($DB, "UPDATE public.controle_login SET password = '".$senhaNova."' WHERE login = '".$_SESSION['login']."'");

      //echo "SELECT * FROM public.avapolos_controle_login WHERE login = '".$login."' AND password = '".$password."' ";
      if($queryEdit){
        $_SESSION['success_msg'] = "Senha atualizada com sucesso!";
      }
    }else{ //erro
      //informa o erro
      if($senhaNova != $senhaNovaR){
        $_SESSION['error_msg'] = "As senhas não batem";
      }else{
        $_SESSION['error_msg'] = "Senha atual incorreta ou usuário não encontrado";
      }      

      header('Location: index.php?page=change-password.php');
      //header('Location: http://www.google.com');
      exit();
    }


  }
?>

<form role="form" id="formfield" action="#" method="post">
  <h5><b>Alterar Senha</b></h5>
  <div class="form-group col-md-4">
    <label for="password">Senha Antiga</label><br>
    <input type="password" name="senha-antiga" placeholder='Digite a senha antiga' class='form-control'>    
  </div>
  <hr>
  <div class="form-group col-md-4">
    <label for="password">Nova Senha</label><br>
    <input type="password" name="senha-nova" placeholder='Digite a nova senha' class='form-control'>    
  </div>
  <div class="form-group col-md-4">
    <label for="password">Repita a Nova Senha</label><br>
    <input type="password" name="senha-nova-r" placeholder='Digite a nova senha novamente' class='form-control'>    
  </div>

    <div class="form-group col-md-4">
      <?php
          if(isset($_SESSION['error_msg']) && $_SESSION['error_msg'] != ''){
      ?>
      <div class='form-group'>
          <div class="alert alert-danger" role="alert">
              <span><?php echo $_SESSION['error_msg']; ?></span>
          </div>
      </div>
      <?php
              unset($_SESSION['error_msg']);
          } //end error msg
      ?>

      <?php
          if(isset($_SESSION['success_msg']) && $_SESSION['success_msg'] != ''){
      ?>
      <div class='form-group'>
          <div class="alert alert-success" role="alert">
              <span><?php echo $_SESSION['success_msg']; ?></span>
          </div>
      </div>
      <?php
              unset($_SESSION['success_msg']);
          } //end error msg
      ?>
    </div>
  
  <button type="submit" name="submitChangePass" value='submitChangePass' id="submitBtn" class="btn btn-success mb-5" >Salvar</button>
</form>