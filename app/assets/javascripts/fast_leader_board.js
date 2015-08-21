var last_tx_id = -1;
var current_tx_id = -1;
var tappers = [];
var tapped = [];
var TOP_N = 5;

$(function() { 
  last_tx_id = current_tx_id = $('#fast_leader_board').attr('last_tx');
  TOP_N = $('#fast_leader_board').attr('top_n');
  	
  setTimeout(check_for_updates, 5000);	
});

function poll_last_tx() {
  $.ajax({
    type: "GET",
    url: $('#fast_leader_board').attr('poll_path'),
    success: function(data) { 
    	current_tx_id = data 
    },
    error: function(xhr, ajaxOptions, thrownError)
     { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); }
  });  
}

function check_for_updates() {
  if ($('#fast_leader_board').length > 0) {
    poll_last_tx();

    if (current_tx_id != last_tx_id) {
      last_tx_id = current_tx_id;
      
      tappers = [];
      tapped = [];
      
      $('.tapper').each(function(idx, element) {
      	tappers.push(element.getAttribute("user"));
      });    	
      
      $('.tapped').each(function(idx, element) {
      	tapped.push(element.getAttribute("tag"));
      });         

      var data_obj = { "tappers": tappers, "tapped": tapped };

      $.ajax({
  	    type: "PUT",
	    data: data_obj,
	    url: $('#fast_leader_board').attr('update_path'),
	    success: function(data) { process_update(data); },
        error: function(xhr, ajaxOptions, thrownError)
         { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); }
      });  
    }
    
    setTimeout(check_for_updates, 5000);	
  }  
}

function process_update(updates) {
  obj = JSON.parse(updates);

  tappers = obj[0];
  tapped = obj[1];  
  
  for (x = 0; x < TOP_N; x++) {
  	if (null != tappers[x]) {
  		$('#tapper_' + x).replaceWith(tappers[x]);
  	}
  }

  for (x = 0; x < TOP_N; x++) {
  	if (null != tapped[x]) {
  		$('#tapped_' + x).replaceWith(tapped[x]);
  	}
  }
}
