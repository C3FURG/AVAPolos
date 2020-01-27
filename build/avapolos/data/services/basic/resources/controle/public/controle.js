function sweet_alert(url, goto="reload", timeout=0) {
	let timerInterval = Swal.fire({
	title: 'Aguarde.. Operação em andamento!',
	allowOutsideClick: false,
	onBeforeOpen: () => {
	Swal.showLoading()
	startTime=0;
	let temporizadorAjax = setInterval(()=>{
	  var request = new XMLHttpRequest();
	    request.onreadystatechange = function() {
	      if(request.readyState === 4) {
	        if(request.status === 200) {
	          let response = request.responseText;
	          if(response == 'true') || ((timeout > 0) && (startTime > timeout)){
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
	    request.open('Get', url);
	    request.send();
			startTime+=5000;
	},5000);
	},
	onClose: () => {
	clearInterval(timerInterval)
	}
})
}
