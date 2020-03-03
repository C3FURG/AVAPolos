<?php
    session_start();

    if(isset($_GET['pg']) && $_GET['pg'] == 'logout'){
        session_destroy();
    }

    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);

    require_once("header.php");
    require("config-control.php");

    //caso tenha enviado o formulário com os dados do login
    if(isset($_POST) && isset($_POST['submitRegister']) && $_POST['submitRegister'] != ''){
        $DB = pg_connect("host=$CFG->dbhost port=$CFG->dbport dbname=$CFG->dbname user=$CFG->dbuser password=$CFG->dbpass") or die('connection failed');

        $FLAG_REGISTRO_EMAIL = TRUE;
        $FLAG_SENHA = TRUE;
         
        
        /*BEGIN email desenvolvedor*/
        //verifica se já não cadastrou o email do desenvolvedor
        $queryRegistro = pg_query($DB, "SELECT * FROM public.controle_registro WHERE id = 1");
        if($queryRegistro && pg_num_rows($queryRegistro) > 0){ //caso ja tenha cadastrado

            $_SESSION['error_msg'] = "- Erro ao salvar informações, dados já cadastrados<br>";

        }else{ //novo cadastro
            $email = filter_input(INPUT_POST, 'email', FILTER_VALIDATE_EMAIL);
            $r_email = filter_input(INPUT_POST, 'email-r', FILTER_VALIDATE_EMAIL);

            if($email == $r_email){
                $queryInsert = pg_query($DB, "INSERT INTO public.controle_registro (id, email_dev) VALUES (1, '".$email."')");

                //echo "SELECT * FROM public.avapolos_controle_login WHERE login = '".$login."' AND password = '".$password."' ";
                if($queryInsert){

                    $FLAG_REGISTRO_EMAIL = TRUE;
                }else{

                    $_SESSION['error_msg'] = "- Erro ao salvar informações<br>";

                    $FLAG_REGISTRO_EMAIL = FALSE;
                }

            }else{

                $_SESSION['error_msg'] = "- Os e-mails informados não conferem<br>";

                $FLAG_REGISTRO_EMAIL = FALSE;

            }
        }
        /*END email desenvolvedor*/

        /*BEGIN senha painel*/
        $senhaNova = md5(filter_input(INPUT_POST, 'senha-nova', FILTER_SANITIZE_SPECIAL_CHARS));
        $senhaNovaR = md5(filter_input(INPUT_POST, 'senha-nova-r', FILTER_SANITIZE_SPECIAL_CHARS));
        if($senhaNova == $senhaNovaR){
            //atualiza a senha
            $queryEdit = pg_query($DB, "UPDATE public.controle_login SET password = '".$senhaNova."', last_login = '".date("Y-m-d H:i:s")."'  WHERE id = 1");

            if($queryEdit){
                //$_SESSION['success_msg'] = "Senha atualizada com sucesso!";
            }else{
                $_SESSION['error_msg'] .= "- Erro ao salvar senha<br>";
            }
        }else{
            $_SESSION['error_msg'] .= "- As senhas não batem<br>";
            $FLAG_SENHA = FALSE;
        }
        /*END senha painel*/


        //caso tenha ocorrido algum erro, retorna e exibe os erros
        if(/*!$FLAG_REGISTRO_EMAIL || */!$FLAG_SENHA){
            header('Location: register.php?pg=erro');
            
        }else{
            header('Location: index.php');
        }
        exit();
    }
?>
<!DOCTYPE html>
<html>
    <body class="bg-dark">
        <div id="layoutAuthentication">
            <div id="layoutAuthentication_content">
                <main>
                    <div class="container">
                        <div class="row justify-content-center">
                            <div class="col-lg-7">
                                <div class="card shadow-lg border-0 rounded-lg mt-5">
                                    <div class="card-header">
                                        <img class='mx-auto d-block' src='img/logoAVA2.png' style='height: 60px;'>
                                        <h3 class="text-center font-weight-light my-4">Configurações</h3>
                                    </div>
                                    <div class="card-body">
                                        <form action='register.php' method='POST' enctype="multipart/form-data">
                                            <!-- <div class="form-row">
                                                <div class="col-md-6">
                                                    <div class="form-group"><label class="small mb-1" for="inputFirstName">First Name</label><input class="form-control py-4" id="inputFirstName" type="text" placeholder="Enter first name" /></div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="form-group"><label class="small mb-1" for="inputLastName">Last Name</label><input class="form-control py-4" id="inputLastName" type="text" placeholder="Enter last name" /></div>
                                                </div>
                                            </div> -->
                                            <!-- <div class="form-group">
                                                <label class="small mb-1" for="inputEmailAddress">E-mail</label>
                                                <input class="form-control py-4" id="inputEmailAddress" type="email" aria-describedby="emailHelp" placeholder="Informe o e-mail" required name='email'/>
                                            </div>

                                            <div class="form-group">
                                                <label class="small mb-1" for="inputEmailAddressR">Repetir E-mail</label>
                                                <input class="form-control py-4" id="inputEmailAddressR" type="email" aria-describedby="emailHelp" placeholder="Repita o e-mail" required name='email-r'/>
                                            </div> -->

                                            <div class="form-group">
                                                <label class="small mb-1" for="inputSenha">Senha</label>
                                                <input class="form-control py-4" id="inputSenha" type="password" placeholder="Informe a senha" required name='senha-nova'/>
                                            </div>

                                            <div class="form-group">
                                                <label class="small mb-1" for="inputSenhaR">Repetir Senha</label>
                                                <input class="form-control py-4" id="inputSenhaR" type="password" placeholder="Repita a senha" required name='senha-nova-r'/>
                                            </div>

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
                                            
                                            <div class="form-group mt-4 mb-0">
                                                <div class="col-md-5 d-block mx-auto">
                                                    <button type='submit' name='submitRegister' value='submitRegister' class="btn btn-primary btn-block">Salvar Configurações</button>
                                                </div>
                                                
                                            </div>
                                        </form>
                                    </div>
                                    <div class="card-footer text-center">
                                        <div class="small"><a href="login.php">Voltar para o login</a></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>

                </main>

            </div>

        </div>
        <footer class="sticky-footer" style='width: 100%;'>
          <div class="container my-auto">
            <div class="copyright text-center my-auto">
              <span>AVAPolos - Levando a educação a distância aonde a Internet não alcança</span> <br> <br>
              <span>Seu IP: <?php echo $_SERVER['REMOTE_ADDR']; ?></span>
            </div>
          </div>
        </footer>
    </body>
</html>
