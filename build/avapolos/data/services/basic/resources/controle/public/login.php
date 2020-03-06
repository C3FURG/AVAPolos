<?php
    session_start();

    if(isset($_GET['pg']) && $_GET['pg'] == 'logout'){
        session_destroy();
    }

    require_once("config-control.php");

    if ($CFG->debug) {
      ini_set('display_errors', 1);
      ini_set('display_startup_errors', 1);
      error_reporting(E_ALL);
    }

    require_once("header.php");
    $DB = pg_connect("host=$CFG->dbhost port=$CFG->dbport dbname=$CFG->dbname user=$CFG->dbuser password=$CFG->dbpass") or die('connection failed');

    
    $queryLoginAdmin = pg_query($DB, "SELECT * FROM public.controle_login WHERE id = 1");
    if($queryLoginAdmin && pg_num_rows($queryLoginAdmin) > 0){
        $dadosLoginAdmin = pg_fetch_array($queryLoginAdmin);
    }

    //caso o last_login seja nulo, quer dizer que ainda não logou, então redireciona para o cadastro
    if(!$dadosLoginAdmin['last_login']){
        header('Location: register.php');
        exit();
    }

    //caso tenha enviado o formulário com os dados do login
    if(isset($_POST) && isset($_POST['submitLogin']) && $_POST['submitLogin'] != ''){
        

        $login = filter_input(INPUT_POST, 'login', FILTER_SANITIZE_SPECIAL_CHARS);
        $password = md5(filter_input(INPUT_POST, 'pass', FILTER_SANITIZE_SPECIAL_CHARS));

        // echo $login;
        // echo $password;

        $queryLogin = pg_query($DB, "SELECT * FROM public.controle_login WHERE login = '".$login."' AND password = '".$password."' ");

        //echo "SELECT * FROM public.avapolos_controle_login WHERE login = '".$login."' AND password = '".$password."' ";
        if($queryLogin && pg_num_rows($queryLogin) > 0){

            $dadosLogin = pg_fetch_array($queryLogin);

            //salva os dados na session para verificar nas páginas
            $_SESSION['login'] = $dadosLogin['login'];

            //salva o last_login como sendo a data atual
            $queryEdit = pg_query($DB, "UPDATE public.controle_login SET last_login = '".date("Y-m-d H:i:s")."' WHERE id = ".$dadosLogin['id']);

            header('Location: index.php');
            //exit();
        }else{
            $dadosLogin = false;

            echo "Login ou senha incorretos";

            $_SESSION['error_msg'] = "Login ou senha incorretos";

            header('Location: login.php?pg=erro');
            //header('Location: http://www.google.com');
            exit();

            //session_destroy();
        }

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
                            <div class="col-lg-5">
                                <div class="card shadow-lg border-0 rounded-lg mt-5">
                                    <div class="card-header">
                                        <img class='mx-auto d-block' src='img/logoAVA2.png' style='height: 60px;'>
                                        <h3 class="text-center font-weight-light my-4">Login</h3>
                                    </div>
                                    <div class="card-body">
                                        <form action='login.php' method='POST' enctype="multipart/form-data">
                                            <div class="form-group">
                                                <label class="small mb-1" for="inputLogin">Login</label>
                                                <input class="form-control py-4" id="inputLogin" name='login' type="text" placeholder="Informe o login" required />
                                            </div>
                                            <div class="form-group">
                                                <label class="small mb-1" for="inputPassword">Senha</label>
                                                <input class="form-control py-4" id="inputPassword" name='pass' type="password" placeholder="Informe a senha" required />
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
                                            <div class="form-group d-flex align-items-center mt-4 mb-0">
                                                <button type='submit' name='submitLogin' value='submitLogin' class="btn btn-success bg-dark d-block mx-auto">Entrar</button>
                                            </div>
                                        </form>
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
