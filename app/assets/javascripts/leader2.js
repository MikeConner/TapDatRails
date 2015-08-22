$(document).ready(function() {
  // Handler for .ready() called.
  firsttime();

  var myVar=setInterval(function(){myTimer()},1000);


});

var lastCheck;

function firsttime() {
  varJsonURL = window.location.href + ".json";
  $.getJSON(  varJsonURL, function( data ) {
    lastCheck = data;
    var leaders = data[0];
    var tapped = leaders["tapped"];
    var latest = leaders["latest"];
    var tappers = leaders["tappers"];

    //if there is a chang or first time
    updatelatest(latest);
    updatetappers(tappers);
    updatetags(tapped);

    });
};

function myTimer() {
    varJsonURL = window.location.href + ".json";
    $.getJSON(  varJsonURL, function( data ) {

      if( JSON.stringify(lastCheck) == JSON.stringify(data)) {
          console.log("no change");
      }
      else{
        lastCheck = data;
        var leaders = data[0];
        var tapped = leaders["tapped"];
        var latest = leaders["latest"];
        var tappers = leaders["tappers"];

        //if there is a chang or first time
        updatelatest(latest);
        updatetappers(tappers);
        updatetags(tapped);
      }
    });
};

function updatetags(tapped){
  var len = tapped.length;
  for (i=1;  i<= len; i++){

    $("#tagrank"+i).html(tapped[i-1]["rank"]);
    $("#tagname"+i).html(tapped[i-1]["name"]);
    $("#tagamount"+i).html("$"+tapped[i-1]["total"]);
    $("#tagtaps"+i).html(tapped[i-1]["taps"]);

    if (tapped[i-1]["image"]==""){
      $("#tagimage"+i).html("<img src='/images/deflb1.png'>");
    }else{
      $("#tagimage"+i).html("<img src='" + tapped[i-1]["image"]+ "'>");
    }

  }


}


function updatetappers(tappers){
  var len = tappers.length;
  for (i=1;  i<= len; i++){

    $("#rank"+i).html(tappers[i-1]["rank"]);
    $("#tapname"+i).html(tappers[i-1]["name"]);
    $("#tapamount"+i).html("$"+tappers[i-1]["total"]);
    $("#taptaps"+i).html(tappers[i-1]["taps"]);

    if (tappers[i-1]["image"]==""){
      $("#tapimage"+i).html("<img src='/images/deflb1.png'>");
    }else{
      $("#tapimage"+i).html("<img src='" + tappers[i-1]["image"]+ "'>");
    }

  }


}

function animatethead(){
  $("#animateme").addClass("animate");
  setTimeout(function(){
    $("#animateme").removeClass("animate");
}, 400);

setTimeout(function(){
  $("#animateme").addClass("animate");
}, 600);

setTimeout(function(){
  $("#animateme").removeClass("animate");
}, 1000);
setTimeout(function(){
  $("#animateme").addClass("animate");
}, 1200);

setTimeout(function(){
  $("#animateme").removeClass("animate");
}, 2000);


}

function updatelatest(latest){

  $("#latestname").html(latest[0]["name"]);
  $("#latestamount").html(latest[0]["amount"]);
  $("#latesttag").html(latest[0]["tag"]);
  $("#latesttagimage").html("<img src='" + latest[0]["yapa"] + "'>");


  if (latest[0]["image"]==""){
    $("#latestuserimage").html("<img src='/images/deflb1.png'>");

  }else{
      $("#latestuserimage").html("<img src='" + latest[0]["image"]+ "'>");
  }
 animatethead();

};
