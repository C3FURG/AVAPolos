function sweet_alert(url) {
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
	          if(response == 'true'){
	            Swal.close();
	            clearInterval(temporizadorAjax);
	            Swal.fire({
	              type: 'success',
	              title: 'Operação realizada com sucesso!',
	              allowOutsideClick: false,
	              html: '<a href=\"javascript:location.reload()\">OK</a>',
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
	},5000);
	},
	onClose: () => {
	clearInterval(timerInterval)
	}
})
}