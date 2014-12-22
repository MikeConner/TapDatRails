function select_dashboard_section(section_id) {
	$('.dash_section').removeClass("active");
	$('.currency_section').removeClass("active");
	
	$('#' + section_id).addClass("active");
}

function set_dashboard_currency(currency_name) {
	$('.dash_section').removeClass("active");
	$('.currency_section').removeClass("active");
	
	var currency_id = currency_name.replace(/\s+/g, '_');
	$('#' + currency_id).addClass("active");
}

// update_user_path = /users/:id (REST update)
function update_nickname(nickname_id, update_user_path) {
  var data_obj = { "user": { "name": $('#' + nickname_id).val() } }
  
  $.ajax({
  	  type: "PUT", 
	  data: data_obj, 
	  url: update_user_path,
	  success: function() { alert('Updated'); },
      error: function(xhr, ajaxOptions, thrownError) 
       { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); }
  });  
}
