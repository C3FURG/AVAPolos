<?php
require_once("php/config.php");

if ($debug) {
	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);
}

$dirArray=(@scandir("backups/"));
if ($dirArray == FALSE) {
  echo "
  <div class='alert alert-danger' role='alert'>
    O diretório de backups não foi encontrado!
  </div>";
  die();
}
?>

<div class="container">
	<div class="row">
		<div class="col-sm">
			<form>
				<div class="form-group">
					<p>Serviços específicos:</p>
					<input class="form-control-input" type="radio" name="moodleRadio" id="moodleRadio" value="moodle">
					<label class="form-control-label" for="moodle">
						Moodle
					</label>
				</div>
				<button id="backupConfirmBtn" class='btn btn-success'>Executar Backup</button>
				<br> <br>
			</form>
		</div>

		<div class="col-sm">
			<form>
			  <div class="form-group">
			    <input type="file" class="form-control-file" id="fileInput">
					<label for="fileInput">Upload do arquivo de backup.</label>
					<br>
					<button id="confirmUpload" type="button" class="btn btn-success" data-toggle="popover" title="Em desenvolvimento" data-content="Funcionalidade em desenvolvimento. Volte um pouco mais tarde.">Upload</button>

			  </div>
			</form>
		</div>
	</div>
</div>

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
        echo "  <td>$size</td>";
        echo "  <td>$date</td>";
        echo "  <td><a href=" . $download_link . ">Baixar</button></td>";
        echo "  <td><button id='backupRestoreBtn' value='$name'>Restaurar</button></td>";
        echo "  <td><button id='backupDeleteBtn' value='$realPath'>Excluir</button></td>";
        echo "</tr>";
      }
    }
    ?>

  </tbody>
</table>

<script type="text/javascript">
  $(document).ready(function(){
  	$('[data-toggle="popover"]').popover()
    $("#backupConfirmBtn").click(function(){
      dataObj = {}
			if ($('#moodleRadio').is(':checked')) {
				dataObj.specific_service = "on"
				dataObj.service = $("#moodleRadio").val();
			} else {
				dataObj.specific_service = "off"
			}
			sweet_alert('php/check.php?get')
      $.get("php/backup.php", dataObj)//.done(function( data ) { alert(data); });
    });

    $("#backupRestoreBtn").click(function(){
			sweet_alert('php/check.php?get')
      $.get("php/backup.php", { restore: $(this).val() })//.done(function( data ) { alert(data); });
    });

    $("#backupDeleteBtn").click(function(){
			sweet_alert('php/check.php?get')
      $.get("php/backup.php", { delete: $(this).val() })//.done(function( data ) {  alert(data); });
    });

  });
</script>


<div class="modal"><!-- Place at bottom of page --></div>

<!-- <br>
Log:
<textarea style="resize: none; min-width: 100%; min-height: 150px" readonly id="log" rows="3"></textarea> -->
