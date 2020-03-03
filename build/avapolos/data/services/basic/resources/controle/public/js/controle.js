function sweet_alert(url, goto="reload") {
	let timerInterval = Swal.fire({
	title: 'Aguarde.. Operação em andamento!',
	allowOutsideClick: false,
	onBeforeOpen: () => {
	Swal.showLoading()
	let temporizadorAjax = setInterval(()=>{
	  var request = new XMLHttpRequest();
	    request.onreadystatechange = function() {
	      if(request.readyState === 4) {
	        if(request.status === 200) {
	          let response = request.responseText;
	          if (response == 'true') {
	            Swal.close();
	            clearInterval(temporizadorAjax);
							boxHtml="";
							if (goto == "reload") {
								boxHtml='<a href=\"javascript:location.reload()\">OK</a>';
							} else {
								boxHtml='<a href=\"' + goto + '\">OK</a>';
							}
	            Swal.fire({
	              type: 'success',
	              title: 'Operação realizada com sucesso!',
	              allowOutsideClick: false,
	              html: boxHtml,
	              showConfirmButton: false
	            })
	          }else{
	            console.log('Ainda não');
	          }
	        } else {
	          console.log(request.status + ' ' + request.statusText);
	        }
	      }
	    }
	    request.open('Post', url);
	    request.send();
	},5000);
	},
	onClose: () => {
	clearInterval(timerInterval)
	}
})
}

function run(string, debug) {
	sweet_alert('/php/check.php')
	data = {};
	if (debug) {
		data.action = "test";
	} else {
		data.action = string;
	}
	$.post("php/action.php", data);
}

//https://stackoverflow.com/questions/4460586/javascript-regular-expression-to-check-for-ip-addresses
function ValidateIPaddress(ipaddress) {
	if (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(ipaddress)) {
		return (true)
	}
	return (false)
}
