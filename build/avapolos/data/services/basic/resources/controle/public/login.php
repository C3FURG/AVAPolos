<!DOCTYPE html>
<html>
    <?php
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
    
    require_once("header.php");
    //include "config.php";
    
    //$infos = $DB->get_record_sql("SELECT * FROM avapolos_sync WHERE tipo = 'I' ORDER BY id DESC LIMIT 1");
    //global $DB;

    

    //return var_dump($infos);

    //caso tenha enviado o formulário com os dados do login
    if(isset($_POST) && isset($_POST['submitLogin']) && $_POST['submitLogin']){
        $DB = pg_connect("host=db_moodle_ies port=5432 dbname=moodle user=moodleuser password=@bancoava.C4p35*&") or die('connection failed');

        $login = filter_input(INPUT_POST, 'login', FILTER_SANITIZE_SPECIAL_CHARS);
        $password = md5(filter_input(INPUT_POST, 'pass', FILTER_SANITIZE_SPECIAL_CHARS));

        $queryLogin = pg_query($DB, "SELECT * FROM public.avapolos_controle_login WHERE login = '".$login."' AND password='".$password."'");

        var_dump(pg_fetch_all($queryLogin));
    }

    ?>

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
                                    </div>
                                    <div class="card-body">
                                        <form action='' method='POST' enctype="multipart/form-data">
                                            <div class="form-group">
                                                <label class="small mb-1" for="inputLogin">Login</label>
                                                <input class="form-control py-4" id="inputLogin" name='login' type="text" placeholder="Informe o login" required />
                                            </div>
                                            <div class="form-group">
                                                <label class="small mb-1" for="inputPassword">Senha</label>
                                                <input class="form-control py-4" id="inputPassword" name='pass' type="password" placeholder="Informe a senha" required />
                                            </div>                                            
                                            <div class="form-group d-flex align-items-center mt-4 mb-0">
                                                <button type='submit' name='submitLogin' value='submitLogin' class="btn btn-success d-block mx-auto">Entrar</button>
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
