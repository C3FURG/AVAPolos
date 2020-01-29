<!-- Sidebar -->

<ul class="sidebar navbar-nav">

  <li class="nav-item <?php if ($page == "home.php") { echo "active"; } ?>">
    <a class="nav-link" href="?page=home.php">
      <i class="fas fa-fw fa-home"></i>
      <span>Página Inicial</span>
    </a>
  </li>

  <li class="nav-item <?php if ($page == "monitor.php") { echo "active"; } ?>">
    <a class="nav-link" href="?page=monitor.php">
      <i class="fas fa-fw fa-tachometer-alt"></i>
      <span>Monitoramento</span>
    </a>
  </li>

  <div class="dropdown-divider"></div>

  <li class="nav-item dropdown">
    <a class="nav-link dropdown-toggle" href="#" id="pagesDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      <i class="fas fa-fw fa-toolbox"></i>
      <span>Administração</span>
    </a>
    <div class="dropdown-menu" aria-labelledby="pagesDropdown">
      <h6 class="dropdown-header"><i class="fas fa-fw fa-tools"></i> Funções</h6>
      <a class="dropdown-item <?php if ($page == "functions.php") { echo "disabled"; } ?>" href="?page=functions.php">Gerais</a>
      <a class="dropdown-item <?php if ($page == "backups.php") { echo "disabled"; } ?>" href="?page=backups.php">Backups</a>
      <div class="dropdown-divider"></div>
      <h6 class="dropdown-header"><i class="fas fa-fw fa-cog"></i> Configurações</h6>
      <a class="dropdown-item <?php if ($page == "configs.php") { echo "disabled"; } ?>" href="?page=configs.php">Gerais</a>
      <a class="dropdown-item <?php if ($page == "network.php") { echo "disabled"; } ?>" href="?page=network.php">Rede</a>
      <a class="dropdown-item <?php if ($page == "sync.php") { echo "disabled"; } ?>" href="?page=sync.php">Sincronização</a>
    </div>
  </li>

</ul>
