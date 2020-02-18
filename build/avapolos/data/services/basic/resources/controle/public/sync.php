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

<link rel="stylesheet" type="text/css" href="css/backups.css">
<script type="text/javascript" src='js/backups.js'></script>

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
			<button id="backupConfirmBtn" type="button" class='bg-dark btn btn-primary'>Executar Sincronização</button>
		</div>

		<div class="col-sm">
			<form>
			  <div class="form-group">
					<label for="fileInput">Upload do arquivo de sincronização</label>
			    <input type="file" class="form-control-file" name="Filesbackup" id="fileupload" multiple data-url="php/backup.php">
			  </div>
			</form>
		</div>

	</div>
</div>

<div class="container-fluid well">
  <div>
    <h6 style='color: rgb(33, 37, 41);'><b>Sincronização Programado</b></h6>
    <div class='col-md-3'>
      <div class='row'>
        <div class='col-lg-6'>
          <div class='form-group'>
            <label class='radio'>
              <input type="radio" class='click-back-prog' name="back-programado" value='habilitado' checked> Habilitado
            </label>
          </div>
        </div>
        <div class='col-lg-6'>
          <div class='form-group'>
            <label class='radio'>
              <input type="radio" class='click-back-prog' name="back-programado" value='desabilitado' > Desabilitado
            </label>
          </div>
        </div>
      </div>
    </div>
    
    
    
  </div>

  <div class="cronjobselector" id='cron-job-backup'>
  <fieldset id="cronjob_expression_picker" class="cron-manual-selector">
      <!-- timeAndDates html copyright and copied from easycron html manual picker -->
      <div class="timesAndDates table-responsive" style="">
          <table class="table" style="margin-bottom: 0px;">
              <thead style="border-top: none !important;">
                  <tr class="maintitle">
                      <th>Hora
                        <span class="questionTip" title="Hora em que o sincronização será realizado, pode selecionar vários horários, segure a tecla CTRL para selecionar mais de um ou clique e arraste com o mouse"><i class="fas fa-question-circle" style="color: rgb(153, 153, 153);"></i></span>
                      </th>
                      <th>Dia do Mês <span class="questionTip" title="Dia do mês em que o sincronização será realizada, segure a tecla CTRL para selecionar mais de um ou clique e arraste com o mouse"><i class="fas fa-question-circle" style="color: rgb(153, 153, 153);"></i></span></th>
                      <th>Dia da Semana <span class="questionTip" title="Dia da semana em que o sincronização será realizada, segure a tecla CTRL para selecionar mais de um ou clique e arraste com o mouse"><i class="fas fa-question-circle" style="color: rgb(153, 153, 153);"></i></span></th>
                  </tr>
              </thead>
              <tbody>
                  <tr class="mainbody">                    
                      <td valign="top"  style='width: 250px'>

                          <ul>
                              <li><label class="radio"><input checked="checked" data-ena="0" data-mode="0" data-name="hours[]" name="all_hours" type="radio" value="1">
                              Todos</label></li>
                              <li><label class="radio"><input data-ena="1" data-mode="2" data-name="hours[]" name="all_hours" type="radio" value="0"> Selecionar Horários</label></li>
                          </ul>
                          <table id="sortableTableNaN">
                              <tbody>
                                  <tr>
                                      <td valign="top">
                                        <select disabled="" multiple="" name="hours[]" size="12">
                                            <option value="0">
                                                0
                                            </option>
                                            <option value="1">
                                                1
                                            </option>
                                            <option value="2">
                                                2
                                            </option>
                                            <option value="3">
                                                3
                                            </option>
                                            <option value="4">
                                                4
                                            </option>
                                            <option value="5">
                                                5
                                            </option>
                                            <option value="6">
                                                6
                                            </option>
                                            <option value="7">
                                                7
                                            </option>
                                            <option value="8">
                                                8
                                            </option>
                                            <option value="9">
                                                9
                                            </option>
                                            <option value="10">
                                                10
                                            </option>
                                            <option value="11">
                                                11
                                            </option>

                                            <option value="12">
                                                12
                                            </option>
                                            <option value="13">
                                                13
                                            </option>
                                            <option value="14">
                                                14
                                            </option>
                                            <option value="15">
                                                15
                                            </option>
                                            <option value="16">
                                                16
                                            </option>
                                            <option value="17">
                                                17
                                            </option>
                                            <option value="18">
                                                18
                                            </option>
                                            <option value="19">
                                                19
                                            </option>
                                            <option value="20">
                                                20
                                            </option>
                                            <option value="21">
                                                21
                                            </option>
                                            <option value="22">
                                                22
                                            </option>
                                            <option value="23">
                                                23
                                            </option>                                    
                                        </select>
                                    </td>
                                  </tr>
                              </tbody>
                          </table>
                      </td>
                      <td valign="top"  style='width: 250px'>
                          <ul>
                              <li><label class="radio"><input checked="checked" data-ena="0" data-mode="0" data-name="days[]" name="all_days" type="radio" value="1"> Todos</label></li>
                              <li><label class="radio"><input data-ena="1" data-mode="2" data-name="days[]" name="all_days" type="radio" value="0"> Selecionar Dias</label></li>
                          </ul>
                          <table id="sortableTableNaN">
                              <tbody>
                                  <tr>
                                      <td valign="top">
                                        <select disabled="" multiple="" name="days[]" size="12">
                                            <option value="1">
                                                1
                                            </option>
                                            <option value="2">
                                                2
                                            </option>
                                            <option value="3">
                                                3
                                            </option>
                                            <option value="4">
                                                4
                                            </option>
                                            <option value="5">
                                                5
                                            </option>
                                            <option value="6">
                                                6
                                            </option>
                                            <option value="7">
                                                7
                                            </option>
                                            
                                          <option value="8">
                                              8
                                          </option>
                                          <option value="9">
                                              9
                                          </option>
                                          <option value="10">
                                              10
                                          </option>
                                          <option value="11">
                                              11
                                          </option>
                                            <option value="12">
                                                12
                                            </option>
                                            <option value="13">
                                                13
                                            </option>
                                            <option value="14">
                                                14
                                            </option>
                                        
                                          <option value="15">
                                              15
                                          </option>
                                          <option value="16">
                                              16
                                          </option>
                                          <option value="17">
                                              17
                                          </option>
                                          <option value="18">
                                              18
                                          </option>
                                          <option value="19">
                                              19
                                          </option>
                                          <option value="20">
                                              20
                                          </option>
                                          <option value="21">
                                              21
                                          </option>
                                          
                                        <option value="22">
                                            22
                                        </option>
                                            <option value="23">
                                                23
                                            </option>
                                            <option value="24">
                                                24
                                            </option>
                                            <option value="25">
                                                25
                                            </option>
                                            <option value="26">
                                                26
                                            </option>
                                            <option value="27">
                                                27
                                            </option>
                                            <option value="28">
                                                28
                                            </option>
                                        <option value="29">
                                              29
                                          </option>
                                          <option value="30">
                                              30
                                          </option>
                                          <option value="31">
                                              31
                                          </option>
                                        </select>

                                        
                                  
                                      </td>
                                  </tr>
                              </tbody>
                          </table>
                      </td>                    
                      <td valign="top">
                          <ul>
                              <li><label class="radio"><input checked="checked" data-ena="0" data-mode="0" data-name="weekdays[]" name="all_weekdays" type="radio" value="1">
                              Todos</label></li>
                              <!-- <li><label class="radio"><input data-ena="1" data-mode="1" data-name="weekdays[]" name="all_weekdays" type="radio" value="3"> Último
                              <span class="questionTip" title="The last chosen weekday of the month"><i class="fas fa-question-circle" style="color: rgb(153, 153, 153);"></i></span></label></li> -->
                              <li><label class="radio"><input data-ena="1" data-mode="2" data-name="weekdays[]" name="all_weekdays" type="radio" value="0"> Selecionar Dias</label></li>
                          </ul>
                          <table id="sortableTableNaN">
                              <tbody>
                                  <tr>
                                      <td valign="top">
                                        <select disabled="" multiple="" name="weekdays[]" size="7" style="width: 200px;">
                                          <option value="0">Domingo</option>
                                          <option value="1">Segunda-feira</option>
                                          <option value="2">Terça-feira</option>
                                          <option value="3">Quarta-feira</option>
                                          <option value="4">Quinta-feira</option>
                                          <option value="5">Sexta-feira</option>
                                          <option value="6">Sábado</option>
                                        </select>
                                      </td>
                                  </tr>
                              </tbody>
                          </table>
                      </td>
                  </tr>
                  
              </tbody>
          </table>
      </div>
      <div class="input-group col-md-5">
      <label class="input-group-addon">Manual Expression</label>
      <input class="form-control" name="manual_expression" type="text" readonly="" id="manual_expression" value="* * * * *">
      </div>
  </fieldset>
  </div>
  <div class='col-md-3'>
    <button class='btn btn-success'>Salvar</button>
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

    $('.click-back-prog').on('click', function(){
      if($(this).val() == 'habilitado'){
        $('#cron-job-backup').show(500);
      }else{
        $('#cron-job-backup').hide(500);
      }
    })

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
