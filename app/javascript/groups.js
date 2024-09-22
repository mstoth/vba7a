// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {

    	var checkedValue = $("#offer").is(':checked');
	
	if (checkedValue ) {
	    $("#notoffer").hide('slow');
	} else {
	    $("#notoffer").show('slow');
	}

    $("#offer").change(function() {

	var checkedValue = $("#offer").is(':checked');
	
	if (checkedValue ) {
	    $("#notoffer").hide('slow');
	} else {
	    $("#notoffer").show('slow');
	}

    } );

    // $('.concert_date').flatpickr({
    // enableTime: true,
    // dateFormat: "F, d Y H:i"
    // });


})
