var myVar=setInterval(function(){myTimer()},5000);
function myTimer() {
    var d = new Date();
    varJsonURL = window.location.href + ".json";

    $.getJSON(  varJsonURL, function( data ) {

//JSON.stringify(leaders)


      var leaders = data[0];
      var tapped = leaders["tapped"];
      var latest = leaders["latest"];
      var tappers = leaders["tappers"];

$("#latestname").html(latest[0]["name"]);
$("#latestamount").html(latest[0]["amount"]);
$("#latesttag").html(latest[0]["tag"]);
$("#latesttagimage").html(latest[0]["yapa"]);
$("#latestuserimage").html(latest[0]["image"]);

document.getElementById("demo").innerHTML = JSON.stringify(tappers);



//go through each array, compare and update values in list below



//      $.each( data, function( key, val ) { items.push( "<li id='" + key + "'>" + val + "</li>" );});

//      $( "<ul/>", { "class": "my-new-list", html: items.join( "" ) }).appendTo( "body" );
    });

    //d.toLocaleTimeString();


}
