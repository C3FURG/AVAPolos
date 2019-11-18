<?php
require_once("php/config.php");
$dirArray=(scandir("backups/"));
?>

<form role="form" >
  <label><input type="checkbox" id="checkbox" name="specific_service">Serviço específico</label>
  <select class="form-control" name="service" id="select1">
    <option>moodle</option>
  </select>
</form>
<br>
<button class='backups_btn_run'>Executar Backup</button>
<br>
<br>

<table class="table">
  <thead>
    <tr>
      <th scope="col">Nome do arquivo</th>
      <th scope="col">Tamanho</th>
      <th scope="col">Data</th>
      <th scope="col">Operação</th>
    </tr>
  </thead>
  <tbody>
    <?php
    foreach ($dirArray as $dir) {
      if (($dir != ".") && ($dir != "..") && ($dir != "notas.txt")) {


        $path="backups/$dir";
        $realPath=realpath($path);
        $name="$dir";
        $date="".date("m/d/Y H:i:s", filemtime("$path"));

        //Função utilizada: https://www.php.net/manual/pt_BR/function.filesize.php
        $bytes = filesize($path);
        $sz = 'BKMGTP';
        $factor = floor((strlen($bytes) - 1) / 3);
        $size = (sprintf("%.2f", $bytes / pow(1024, $factor)) . @$sz[$factor]);

        $download_link = $siteName . "/" . $path;

        echo "<tr>";
        echo "  <th scope='row'>$dir</th>";
        #echo "  <td></td>";
        echo "  <td>$size</td>";
        echo "  <td>$date</td>";
        echo "  <td><a href=" . $download_link . ">Baixar</button></td>";
        echo "  <td><button class='backups_btn_restore' id='$name'>Restaurar</button></td>";
        echo "  <td><button class='backups_btn_delete' id='$realPath'>Excluir</button></td>";
        echo "</tr>";
      }
    }
    ?>

  </tbody>
</table>

<script type="text/javascript">
  $(document).ready(function(){
    $(".backups_btn_run").click(function(){
      dataObj = {}
      service=$("#select1").val();
      dataObj.service = service
      if ($('#checkbox').is(':checked')) {
        dataObj.specific_service = "on"
      } else {
        dataObj.specific_service = "off"
      }
      //$.get("php/backup.php", dataObj).done(function( data ) { $('#log').html(data); });
      alert('auau');
      sweet_alert('php/check.php?get')
    });

    $(".backups_btn_restore").click(function(){
      $.get("php/backup.php", { restore: $(this).attr('id') }).done(function( data ) { $('#log').html(data); });
      sweet_alert('php/check.php?get')
    });

    $(".backups_btn_delete").click(function(){
      $.get("php/backup.php", { delete: $(this).attr('id') }).done(function( data ) {  $('#log').html(data); });
      sweet_alert('php/check.php?get')
    });

  });
</script>

<div class="modal"><!-- Place at bottom of page --></div>

<!-- <br>
Log:
<textarea style="resize: none; min-width: 100%; min-height: 150px" readonly id="log" rows="3"></textarea> -->
