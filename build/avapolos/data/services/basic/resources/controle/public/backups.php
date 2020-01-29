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
<div id="progress" class="progress">
    <div class="progress-bar bg-dark progress-bar-striped progress-bar-animated"></div>
</div>
<div class="container-fluid well">
	<div class="row">

		<div class="col-sm">
			<p>Serviços específicos</p>
			<input type="checkbox" id="moodleCheck" value="moodle">
			<label for="moodle">Moodle</label>
			<br>
			<button id="backupConfirmBtn" type="button" class='bg-dark btn btn-primary'>Executar Backup</button>
		</div>

		<div class="col-sm">
			<form>
			  <div class="form-group">
					<label for="fileInput">Upload do arquivo de backup</label>
			    <input type="file" class="form-control-file" name="Filesbackup" id="fileupload" multiple data-url="php/backup.php">
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

        $bytes = filesize($path);
        $sz = 'BKMGTP';
        $factor = floor((strlen($bytes) - 1) / 3);
        $size = (sprintf("%.2f", $bytes / pow(1024, $factor)) . @$sz[$factor]);

        $download_link = $path;

        echo "<tr>";
        echo "  <th scope='row'>$dir</th>";
        echo "  <td>$size</td>";
        echo "  <td>$date</td>";
        echo "  <td><a href=" . $download_link . ">Baixar</button></td>";
        echo "  <td><button class='bg-dark btn btn-primary' id='backupRestoreBtn' value='$realPath'>Restaurar</button></td>";
        echo "  <td><button class='bg-dark btn btn-primary' id='backupDeleteBtn'  value='$realPath'>Excluir</button></td>";
        echo "</tr>";
      }
    }
    ?>

  </tbody>
</table>

<style media="screen">
.well {
  min-height: 20px;
  padding: 19px;
  margin-bottom: 20px;
  background-color: #f5f5f5;
  border: 1px solid #e3e3e3;
  border-radius: 4px;
}
</style>

<script src="vendor/jquery.ui.widget.js" type="text/javascript"></script>
<script src="vendor/jquery.iframe-transport.js" type="text/javascript"></script>
<script src="vendor/jquery.fileupload.js" type="text/javascript"></script>

<script type="text/javascript">

  $(document).ready(function(){

		debug=<?php if ($debug) { echo "true;"; } else echo "false;";?>

    $("#backupConfirmBtn").click(function(){
      dataObj = {}
			if ($('#moodleCheck').is(':checked')) {
				dataObj.service = $("#moodleCheck").val();
			}

			sweet_alert('php/check.php?get')
			if (debug) {
				$.get("php/action.php?action=test");
			} else {
				$.get("php/backup.php", dataObj);
			}
    });

    $("#backupRestoreBtn").click(function(){
			// sweet_alert('php/check.php?get')
      $.get("php/backup.php", { restore: $(this).val() }).done(function( data ) { alert(data); });
    });

    $("#backupDeleteBtn").click(function(){
      $.get("php/backup.php", { delete: $(this).val() });
			setTimeout(function () {
				location.reload();
			}, 1000);
    });

		$(function () {
        $('#fileupload').fileupload({
            dataType: 'json',
            done: function (e, data) {
							if (data.result == 1) {
								setTimeout(function () {
									$('#progress .progress-bar').css('width', '0%');
								}, 500);
								setTimeout(function () {
									location.reload()
								}, 1000);
							} else {
								setTimeout(function () {
									$('#progress .progress-bar').removeClass('bg-dark');
									$('#progress .progress-bar').addClass('bg-danger');
								}, 500);
								setTimeout(function () {
									location.reload()
								}, 1000);
							}
            },
            progressall: function (e, data) {
                var progress = parseInt(data.loaded / data.total * 100, 10);
                $('#progress .progress-bar').css('width', progress + '%');
            }
        });
    });

  });
</script>
