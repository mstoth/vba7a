// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.



// $( function() {
//     var handle = $( "#custom-handle" );
//     $( "#slider" ).slider({
//       create: function() {
//         handle.text( $( this ).slider( "value" ) );
//       },
//       slide: function( event, ui ) {
//         handle.text( ui.value );
//       }
//     });
//   } );

  $(".slider").slider({
	min: 0,
	max: 100,
	from: document.getElementById("slider").value,
	onStart: function(data) {
	    document.getElementById("distlbl").innerHTML=
		data.input.prop("value")
	},

	onFinish: function(data) {
	    document.getElementById("slider").innerHTML=data.input.prop("value")
	    $("#disthid").innerHTML=data.input.prop("value")
	}
    });


$(".js-range-slider").ionRangeSlider({
    min: 0,
    max: 100,
    from: document.getElementById("disthid").value,
    onStart: function(data) {
	document.getElementById("distlbl").innerHTML=
	    data.input.prop("value")
    },

    onFinish: function(data) {
	document.getElementById("distlbl").innerHTML=data.input.prop("value")
	$("#disthid").value=data.input.prop("value")
    }
});
