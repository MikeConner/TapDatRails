// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require_tree .

$(window).ready(function(){
  setTimeout(function(){
    setTimeout(function(){
      $('#container').append('<div class="dot" style="top:50%;left:50%;"></div>')
    },900);
    setTimeout(function(){
      $('#container').append('<div class="dot" style="top:50%;left:50%;"></div>')
    },600);
    setTimeout(function(){
      $('#container').append('<div class="dot" style="top:50%;left:50%;"></div>')
    },300);
    setTimeout(function(){
      $('#container').append('<div class="dot" style="top:50%;left:50%;"></div>')
    },0);
    setTimeout(function(){
      $('#container .dot').remove();
    },2900);
  },1500);
});


// click animation

if (Modernizr.touch) {   
    $('#container').on('touchstart',function(e) {
      var left = e.originalEvent.touches[0].pageX;
      var top = e.originalEvent.touches[0].pageY;

      $(this).append('<div class="dot" style="top:'+top+'px;left:'+left+'px;"></div>')
      setTimeout(function(){
        $('#container .dot:first-of-type').remove();
      },3000);
    });
    document.body.addEventListener('touchmove',function(e){
        e.preventDefault();
    });
} else {   
    $('#container').on('mousedown',function(e) {
      var left = e.pageX;
      var top = e.pageY;

      $(this).append('<div class="dot" style="top:'+top+'px;left:'+left+'px;"></div>')
      setTimeout(function(){
        $('#container .dot:first-of-type').remove();
      },3000);
    }); 
}

$(function(){ $(document).foundation(); });
