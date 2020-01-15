<form>
  <div class="form-group form-check">
    <input type="checkbox" class="form-check-input" id="dhcpInput">
    <label class="form-check-label" for="dhcpInput">Prover DHCP?</label>
  </div>
  <div class="form-group">
    <label for="ipInput">IP Manual</label>
    <input id="ipInput" class="form-control" type="text">
  </div>
  <div class="form-group">
    <label for="remoteIpInput">IP do POLO remoto.</label>
    <input id="remoteIpInput" class="form-control" type="text">
  </div>
  <button id="submitBtn" type="button" class="btn btn-primary" data-toggle="popover" title="Em desenvolvimento" data-content="Funcionalidade em desenvolvimento. Volte um pouco mais tarde.">Salvar</button>
</form>

<script type="text/javascript">
  $(document).ready(function(){
  	$('[data-toggle="popover"]').popover();
  });
</script>
