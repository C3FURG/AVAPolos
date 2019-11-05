<?php

$subject="";

if (isset($_GET['subject'])) {
  switch ($_GET['subject']) {
    case 'educapes_download':
    $subject="educapes_download";
    break;

    case 'service':
    $subject="service";
    break;

    default:
      $subject="none";
      break;

  }
}
#echo $subject;
?>

<a href="?page=monitor.php&subject=service" class="btn btn-primary<?php if ($subject == "service") { echo "disabled"; } ?>">Serviço</a>
<a href="?page=monitor.php&subject=educapes_download" class="btn btn-primary<?php if ($subject == "educapes_download") { echo "disabled"; } ?>">Download eduCAPES</a>

<br>

<p>Monitoramento: <?php echo $subject; ?></p>

<textarea style="resize: none; min-width: 100%; min-height: 300px;" readonly id="log" rows="3"></textarea>

<script type="text/javascript">
  $(document).ready(function(){

    $.get( "php/action.php?action=get_progress&subject=<?php echo $subject; ?>", function( data ) {
      $( "#log" ).html( data );
      //alert( data );
    });

    setInterval(function() {
      $.get( "php/action.php?action=get_progress&subject=<?php echo $subject; ?>", function( data ) {
        $( "#log" ).html( data );
        //alert( data );
      });
    }, 2000);

  });
</script>
