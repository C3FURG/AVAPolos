// EASYCRON.com like manual cron job schedule picker

$(document).ready(function(){
  // initialize cronjob picker control
  var default_expression = $('#manual_expression').val();
  cronjob_expression_picker(
    '#cronjob_expression_picker', default_expression
  );
  
  // add event handler for manual picker
  $('#parseaction').click(function(e) {
    e.preventDefault();
    var custom_expression = $('#custom_expression').val();
    cronjob_expression_parsing_to_param(
      '#cronjob_expression_picker', custom_expression
    );
  });
  
  // end
});

// function cronjob
// parsing available expression value
function cronjob_expression_parsing_to_param(element, value) {	
	var picker = $(element);
	
	var all_mins = element + ' input[name="all_mins"]';
	var all_hours = element + ' input[name="all_hours"]';
	var all_days = element + ' input[name="all_days"]';
	var all_months = element + ' input[name="all_months"]';
	var all_weekdays = element + ' input[name="all_weekdays"]';
	
	var mins_sel = element + ' select[name="mins[]"]';
	var hours_sel = element + ' select[name="hours[]"]';
	var days_sel = element + ' select[name="days[]"]';
	var months_sel = element + ' select[name="months[]"]';
	var weekdays_sel = element + ' select[name="weekdays[]"]';
	var ordinal_input = element + ' input[name="ordinal"]';
	
	var valuearray = value.split(' ');
	if(valuearray.length != 5) {
		valuearray = ['*','*','*','*','*'];
	}
	
	var mins_param = valuearray[0];	
	var hours_param = valuearray[1];	
	var days_param = valuearray[2];	
	var months_param = valuearray[3];	
	var weekdays_param = valuearray[4];	
	
	// mins set...
	if(mins_param == "*") {
		$(all_mins + '[value="1"]').click().change();
	}else{
		$(all_mins + '[value="0"]').click().change();
		var mins_param_array = mins_param.split(',');
		for(var i = 0;i < mins_param_array.length; i++) {
			$(mins_sel + ' option[value="' + mins_param_array[i] + '"]').attr('selected', 'selected');
		}
	}
	
	// hours set...
	if(hours_param == "*") {
		$(all_hours + '[value="1"]').click().change();
	}else{
		$(all_hours + '[value="0"]').click().change();
		var hours_param_array = hours_param.split(',');
		for(var i = 0;i < hours_param_array.length; i++) {
			$(hours_sel + ' option[value="' + hours_param_array[i] + '"]').attr('selected', 'selected');
		}
	}
	
	// days set...
	if(days_param == "*") {
		$(all_days + '[value="1"]').click().change();
	}else if(days_param.indexOf('W') != -1) {
		$(all_days + '[value="4"]').click().change();
		
		var days_param_val = days_param.replace('W','');
		if(days_param_val != '')
			$(days_sel + ' option[value="' + days_param_val + '"]').attr('selected', 'selected');
	}else if(days_param.indexOf('L') != -1) {
		$(all_days + '[value="3"]').click().change();
	}else{
		$(all_days + '[value="0"]').click().change();
		var days_param_array = days_param.split(',');
		for(var i = 0;i < days_param_array.length; i++) {
			$(days_sel + ' option[value="' + days_param_array[i] + '"]').attr('selected', 'selected');
		}
	}
	
	// months set...
	if(months_param == "*") {
		$(all_months + '[value="1"]').click().change();
	}else{
		$(all_months + '[value="0"]').click().change();
		var months_param_array = months_param.split(',');
		for(var i = 0;i < months_param_array.length; i++) {
			$(months_sel + ' option[value="' + months_param_array[i] + '"]').attr('selected', 'selected');
		}
	}
	
	// weekdays set...
	console.log(weekdays_param);
	if(weekdays_param == "*") {
		$(all_weekdays + '[value="1"]').click().change();
	}else if(weekdays_param.indexOf('#') != -1) {
		$(all_weekdays + '[value="4"]').click().change();
		var weekdays_param_val_array = weekdays_param.split('#');
		if(weekdays_param_val_array.length == 2) {
			var param1 = weekdays_param_val_array[0];
			var param2 = weekdays_param_val_array[1];
			$(ordinal_input).val(param2);
			console.log(param1);
			if(param1 != '') {
				$(weekdays_sel + ' option[value="' + param1 + '"]').attr('selected', 'selected');
			}
		}
	}else if(weekdays_param.indexOf('L') != -1) {
		$(all_weekdays + '[value="3"]').click().change();
		var weekdays_param_val = weekdays_param.replace('L','');
		if(weekdays_param_val != '')
			$(weekdays_sel + ' option[value="' + weekdays_param_val + '"]').attr('selected', 'selected');
	}else{
		$(all_weekdays + '[value="0"]').click().change();
		var weekdays_param_array = weekdays_param.split(',');
		for(var i = 0;i < weekdays_param_array.length; i++) {
			$(weekdays_sel + ' option[value="' + weekdays_param_array[i] + '"]').attr('selected', 'selected');
		}
	}
	
}

// custom function for initialize custom expression picker
function cronjob_expression_picker(element, value) {
	var picker = $(element);
	
	var all_mins = element + ' input[name="all_mins"]';
	var all_hours = element + ' input[name="all_hours"]';
	var all_days = element + ' input[name="all_days"]';
	var all_months = element + ' input[name="all_months"]';
	var all_weekdays = element + ' input[name="all_weekdays"]';
	
	var mins_sel = element + ' select[name="mins[]"]';
	var hours_sel = element + ' select[name="hours[]"]';
	var days_sel = element + ' select[name="days[]"]';
	var months_sel = element + ' select[name="months[]"]';
	var weekdays_sel = element + ' select[name="weekdays[]"]';
	
	var ordinal_input = element + ' input[name="ordinal"]';
	
	$(days_sel + ',' + weekdays_sel).change(function(e){
		var val = $(this).parents('table').eq(0).parents('td').eq(0).find('input[type="radio"]:checked').val();
		var name = $(this).parents('table').eq(0).parents('td').eq(0).find('input[type="radio"]').attr('name');
		var curval = e.currentTarget.value;
		var trselect = $(this).parents('tr').eq(0).find('select');

		if((name == "all_weekdays" && val == "3") || (name == "all_weekdays" && val == "4") || (name == "all_days" && val == "4")) {
			$(trselect).find('option:selected').each(function(){
				if($(this).val() != curval) $(this).removeAttr('selected');
			});
		}
	});
	
	$(all_mins + ',' + all_hours + ',' + all_days + ',' + all_months + ',' + all_weekdays).change(function(e){
		var val = $(this).val();
		var name = $(this).attr('name');
		if(name == "all_weekdays") $(this).parents('td').eq(0).find('input[name="ordinal"]').prop('disabled', true);
		
		switch(val) {
			case '1':
				// disable list
				$(this).parents('td').eq(0).find('select').prop('disabled', true);
				$(this).parents('td').eq(0).find('select option:selected').removeAttr('selected');
				break;
			case '2':
			case '3':
				if(name == "all_days")
					$(this).parents('td').eq(0).find('select').prop('disabled', true);
				else if(name == "all_weekdays")
					$(this).parents('td').eq(0).find('select').prop('disabled', false);
				break;
			case '4':
				if(name == "all_weekdays") {
					$(this).parents('td').eq(0).find('select').prop('disabled', false);
					$(this).parents('td').eq(0).find('input[name="ordinal"]').prop('disabled', false);
				}else{
					$(this).parents('td').eq(0).find('select').prop('disabled', false);
				}
				break;
			case '5':
			default:
				$(this).parents('td').eq(0).find('select').prop('disabled', false);
				break;
		}
		
		cronjob_expression_parsing(element);
	});
	
	$(all_mins).eq(0).click().change();
	$(all_hours).eq(0).click().change();
	$(all_days).eq(0).click().change();
	$(all_months).eq(0).click().change();
	$(all_weekdays).eq(0).click().change();
	
	// set event trigger
	$(mins_sel + ',' + hours_sel + ',' + days_sel + ',' + months_sel + ',' + weekdays_sel + ',' + ordinal_input).on('change', function() {
		cronjob_expression_parsing(element);
	});
	
	// parsing from already entry value if any
	if(value != null && value != "") {
		cronjob_expression_parsing_to_param(element, value);
	}
	
	// parsing every change interactions
	cronjob_expression_parsing(element);
	
}

function cronjob_expression_parsing(element) {
	var picker = $(element);
	
	var all_mins = element + ' input[name="all_mins"]';
	var all_hours = element + ' input[name="all_hours"]';
	var all_days = element + ' input[name="all_days"]';
	var all_months = element + ' input[name="all_months"]';
	var all_weekdays = element + ' input[name="all_weekdays"]';
	
	var all_mins_val = $(all_mins + ':checked').val();
	var all_hours_val = $(all_hours + ':checked').val();
	var all_days_val = $(all_days + ':checked').val();
	var all_months_val = $(all_months + ':checked').val();
	var all_weekdays_val = $(all_weekdays + ':checked').val();
	
	var mins_sel = element + ' select[name="mins[]"]';
	var hours_sel = element + ' select[name="hours[]"]';
	var days_sel = element + ' select[name="days[]"]';
	var months_sel = element + ' select[name="months[]"]';
	var weekdays_sel = element + ' select[name="weekdays[]"]';
	
	var mins_sel_val = $(mins_sel).map(function(){return $(this).val();}).get();
	var hours_sel_val = $(hours_sel).map(function(){return $(this).val();}).get();
	var days_sel_val = $(days_sel).map(function(){return $(this).val();}).get();
	var months_sel_val = $(months_sel).map(function(){return $(this).val();}).get();
	var weekdays_sel_val = $(weekdays_sel).map(function(){return $(this).val();}).get();
	var weekdays_th_val = $(element + ' input[name="ordinal"]').val();
	var result_array = ["*", "*", "*", "*", "*"];
	
	// check first for mins...;
	if(all_mins_val == "0" && mins_sel_val.length > 0) {
		result_array[0] = mins_sel_val.join(',');
	}
	
	// check first for hours...;
	if(all_hours_val == "0" && hours_sel_val.length > 0) {
		result_array[1] = hours_sel_val.join(',');
	}
	
	// check first for days...;
	if(all_days_val == "0" && days_sel_val.length > 0) {
		result_array[2] = days_sel_val.join(',');
	}else if(all_days_val == "3") { // check third for days...;
		result_array[2] = "L";
	}else if(all_days_val == "4") { // check fourth for days...;
		result_array[2] = days_sel_val.join(',') + "W";
	}
	
	// check first for months...;
	if(all_months_val == "0" && months_sel_val.length > 0) {
		result_array[3] = months_sel_val.join(',');
	}
	
	// check first for weekdays...;
	if(all_weekdays_val == "0" && weekdays_sel_val.length > 0) {
		result_array[4] = weekdays_sel_val.join(',');
	}else if(all_weekdays_val == "3") {
		result_array[4] = weekdays_sel_val.join(',') + "L";
	}else if(all_weekdays_val == "4") {
		result_array[4] = weekdays_sel_val.join(',') + "#" + weekdays_th_val;
	}
	
	// result to manual_expression input
	$('input[name="manual_expression"]').val(result_array.join(' '));
}