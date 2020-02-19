<?php
require_once('header.php');
require_once('config.php');
if ($CFG->debug) {
  ini_set('display_errors', 1);
  ini_set('display_startup_errors', 1);
  error_reporting(E_ALL);
}
?>

<html>
  <body>
  <div class="jumbotron"></div>

  <div class="container">
    <div class="well">
      <h1 class="display-1 text-center">401</h1>
      <p class="lead text-center">Você não pode acessar esse recurso.</p>
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
