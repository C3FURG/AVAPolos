<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$page="home.php";
if (isset($_GET['page'])) {
  $page=$_GET['page'];
}

?>

<!DOCTYPE html>
<html lang="en">

<?php require_once("header.php"); ?>

<body id="page-top">

  <?php require_once("nav.php"); ?>

  <div id="wrapper">

    <?php require_once("sidebar.php"); ?>

    <div id="content-wrapper">

      <div class="container-fluid">

        <div id="page">

          <?php if ( ! file_exists($page) ) { require_once("404.php"); } else { require_once($page); } ?>

        </div>

      <?php require_once("footer.php"); ?>

    </div>
    <!-- /.content-wrapper -->

  </div>
  <!-- /#wrapper -->

</body>

</html>
