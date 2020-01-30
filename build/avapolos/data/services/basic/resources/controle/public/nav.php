<nav class="sb-topnav navbar navbar-expand navbar-dark bg-dark">
  <a class="navbar-brand" href="index.html"><img src='img/logoAVA2_white.png' style='height: 30px;'></a>
  <!-- User Dropdown -->
  <ul class="navbar-nav ml-auto mr-0 mr-md-3 my-2 my-md-0">
      <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" id="userDropdown" href="#" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="fas fa-user fa-fw"></i></a>
          <div class="dropdown-menu dropdown-menu-right" aria-labelledby="userDropdown">
              <a class="dropdown-item disabled" href="#"><?php echo $_SESSION['login']; ?></a>
              <!-- <a class="dropdown-item" href="#">Settings</a><a class="dropdown-item" href="#">Activity Log</a>  -->
              <div class="dropdown-divider"></div>
              <a class="dropdown-item" href="login.php?pg=logout">Sair</a>
          </div>
      </li>
  </ul>
</nav>
