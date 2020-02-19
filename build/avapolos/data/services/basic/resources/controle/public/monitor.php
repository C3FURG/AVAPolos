<?php
require_once('config.php');
if ($CFG->debug) {
  ini_set('display_errors', 1);
  ini_set('display_startup_errors', 1);
  error_reporting(E_ALL);
}
?>

<link rel="stylesheet" href="vendor/xterm/xterm.css" type="text/css"/>
<script src="vendor/xterm/xterm.js" charset="utf-8"></script>
<script src="vendor/xterm/FitAddon.js" charset="utf-8"></script>

<div class="well">
  <p>Selecione o objeto que deseja monitorar.</p>
  <button type="button" class="bg-dark btn btn-primary monitor_btn" id="service">Serviço AVAPolos</button>
  <button type="button" class="bg-dark btn btn-primary monitor_btn" id="educapes_download">Download do eduCAPES</button>
</div>

<div class="container">
  <div class="well">
    <div id="terminal">
      <script>
        $(document).ready(function(){

          var subject = "service";
          $( ".monitor_btn" ).click(function() {
            subject = $(this).attr('id');
          });

          debug = <?php echo ($CFG->debug) ? 'true' : 'false'; ?>;

          const terminal = new Terminal();
          const fitAddon = new FitAddon();

          terminal.open(document.getElementById('terminal'));
          terminal.loadAddon(fitAddon);
          fitAddon.fit();

          data = {}
          data.action = "get_log";
          data.subject = subject;

          $.post("php/action.php", data).done(function(data) {
            terminal.clear();
            terminal.write(data);
          });

          setInterval(function () {
            console.log(data);
            console.log(subject);
            data.subject = subject;
            $.post("php/action.php", data).done(function(data) {
              terminal.clear();
              terminal.write(data);
            });
          }, 1000);


        });

    </script>
  </div>

  </div>

</div>
