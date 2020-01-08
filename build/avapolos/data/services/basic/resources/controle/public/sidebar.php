<!-- Sidebar -->
<ul class="sidebar navbar-nav">
  <li class="nav-item <?php if ($page == "home.php") { echo "active"; } ?>">
    <a class="nav-link" href="?page=home.php">
      <i class="fas fa-fw fa-home"></i>
      <span>Home</span>
    </a>
  </li>
  <li class="nav-item <?php if ($page == "monitor.php") { echo "active"; } ?>">
    <a class="nav-link" href="?page=monitor.php">
      <i class="fas fa-fw fa-tachometer-alt"></i>
      <span>Monitoramento</span>
    </a>
  </li>
  <li class="nav-item <?php if ($page == "backups.php") { echo "active"; } ?>">
    <a class="nav-link" href="?page=backups.php">
      <i class="fas fa-fw fa-folder"></i>
      <span>Backups</span>
    </a>

  </li>
  <li class="nav-item <?php if ($page == "functions.php") { echo "active"; } ?>">
    <a class="nav-link" href="?page=functions.php">
      <i class="fas fa-fw fa-table"></i>
      <span>Funções</span></a>
  </li>

  <li class="nav-item <?php if ($page == "dyndns.php") { echo "active"; } ?>">
    <a class="nav-link" href="?page=dyndns.php">
      <i class="fas fa-fw fa-cog"></i>
      <span>DNS Dinâmico</span></a>
  </li>
</ul>
