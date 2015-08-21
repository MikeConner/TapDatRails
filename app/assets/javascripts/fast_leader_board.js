var last_tapper_hash = "";
var tappers = [];
var tapped = [];

$(function(){ 
  last_tapper_hash = compute_hash();

  setTimeout(check_for_updates, 5000);	
});

function compute_hash() {
  return $('#last_tapper_name').text() + "_" + $('#last_tapper_amount').text() + "_" + $('#last_tapper_tag').text();	
}

function check_for_updates() {
  if ($('#fast_leader_board').length > 0) {
    var current_hash = compute_hash();
  
    if (current_hash != last_tapper_hash) {
      tappers = [];
      tapped = [];
      
      $('.tapper').each(function(idx, element) {
      	tappers.push(element.getAttribute("user"));
      });    	
      
      $('.tapped').each(function(idx, element) {
      	tapped.push(element.getAttribute("tag"));
      });         
    }
  
    setTimeout(check_for_updates, 5000);	
  }  
}
