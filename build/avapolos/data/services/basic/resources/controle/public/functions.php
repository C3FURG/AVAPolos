<script type="text/javascript">
  $(document).ready(function(){

    function run(string) {
        $.get( "php/action.php", { action: string }).done(function( data ) { $('#log').html(data); });
    }

    $(".painel_btn").click(function(e) {
      //alert($(this).attr('id'));
      run($(this).attr('id'));
    })

  });

</script>

<p>Download do eduCAPES:</p>
<button class="painel_btn" id="download_start_educapes">Iniciar(Resumir)</button>
<button class="painel_btn" id="download_stop_educapes">Parar</button>
<br>

<br>
<p>Execução da solução:</p>
<button class="painel_btn" id="start">Iniciar</button>
<button class="painel_btn" id="stop">Parar</button>
<br>

<br>
<p>Modo de acesso:</p>
<button class="painel_btn" id="access_mode_ip">IP</button>
<button class="painel_btn" id="access_mode_name">Nomes</button>
<br>


<br>
Log:
<textarea style="resize: none; min-width: 100%; min-height: 150px" readonly id="log" rows="3"></textarea>
