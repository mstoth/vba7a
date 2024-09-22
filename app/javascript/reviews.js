jQuery(function($) {

  $("#review_stars").on("change",function () {
    var me = $(this);
    var v = document.getElementById("review_stars").value
    document.getElementsByClassName('sitems')[5-v].checked=true 
  });

  $('[type*="radio"]').on("click",function () {
      var me = $(this);
      document.getElementById("review_stars").value = me.attr('value');
      //$('.stars').html(me.attr('value'));
      //$('#starsid').html = me.attr('value');
    });
  });
  
  
