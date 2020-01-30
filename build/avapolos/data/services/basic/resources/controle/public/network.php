<div class="row">
  <div class="col-sm">
    <div class="well">
      <p class="text-center">Modo de acesso</p>
      <div class="text-center">
        <button class="bg-dark btn btn-primary painel_btn" id="access_mode_ip">IP</button>
        <button class="bg-dark btn btn-primary painel_btn" id="access_mode_name">Nomes</button>
      </div>
    </div>
  </div>
</div>
<div class="row">
  <div class="col-sm">
    <form class="well">
      <div class="form-group form-check">
        <input type="checkbox" class="form-check-input" id="dhcpCheck">
        <label class="form-check-label" for="dhcpInput">Prover DHCP?</label>
      </div>
      <div class="form-group">
        <label for="ipInput">IP Manual</label>
        <input id="ipInput" class="form-control" type="text">
      </div>
      <button id="submitBtn" type="button" class="bg-dark btn btn-primary">Salvar</button>
    </form>
  </div>
</div>
