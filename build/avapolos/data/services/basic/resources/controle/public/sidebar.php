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
      <h6 class="dropdown-header"><i class="fas fa-fw fa-tools"></i> Funções:</h6>
      <a class="dropdown-item <?php if ($page == "functions_general.php") { echo "disabled"; } ?>" href="?page=functions_general.php">Gerais</a>
      <a class="dropdown-item <?php if ($page == "functions_backups.php") { echo "disabled"; } ?>" href="?page=functions_backups.php">Backups</a>
      <div class="dropdown-divider"></div>
      <h6 class="dropdown-header"><i class="fas fa-fw fa-network-wired"></i> Rede:</h6>
      <a class="dropdown-item <?php if ($page == "network_general.php") { echo "disabled"; } ?>" href="?page=network_general.php">Geral</a>
      <a class="dropdown-item <?php if ($page == "network_dhcp.php") { echo "disabled"; } ?>" href="?page=network_dhcp.php">DHCP</a>
      <a class="dropdown-item <?php if ($page == "network_dns.php") { echo "disabled"; } ?>" href="?page=network_dns.php">DNS</a>
      <div class="dropdown-divider"></div>
      <h6 class="dropdown-header"><i class="fas fa-fw fa-sync"></i> Sincronização:</h6>
      <a class="dropdown-item <?php if ($page == "sync.php") { echo "disabled"; } ?>" href="?page=sync.php">Online</a>
    </div>
  </li>
  <li class="nav-item <?php if ($page == "report.php") { echo "active"; } ?>">
    <a class="nav-link" href="?page=report.php">
      <i class="fas fa-flag"></i>
      <span>Reportar Problema</span></a>
  </li>

</ul>
