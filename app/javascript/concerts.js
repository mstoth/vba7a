

jQuery(function() {

	var ocb = document.getElementById("offer_check_box");
	
	if (ocb != null) {
		ocb.onclick = function() {
			var checkedValue = $("#offer_check_box").is(':checked');
			if (checkedValue) {
				$(".offer").show('slow');
				$(".notoffer").hide('slow');
			} else {
				$(".offer").hide('slow')
				$(".notoffer").show('slow');
			}
		};
	} 

	document.addEventListener('click', document.getElementById("no_webpage"), function() {
		var wpbox = document.getElementById("no_webpage");
		var checkedValue = wpbox.is(':checked');
		var tbox = document.getElementById("concert_webpage")
		var val = tbox.value
		if (checkedValue) {
		tbox.value = "Use Group Website";
		tbox.disabled = true;
		} else {
		tbox.disabled = false;
		tbox.value = "https://" + val;
		}
	});
	
	
	flatpickr('.concert_date',

		  {
		      onChange: function(selectedDates, dateStr, instance) {
			  //...
			  alert('onchange');
		      },
		      onOpen: [
			  function(selectedDates, dateStr, instance){
			      //...
			      alert('onopen');
			  },
			  function(selectedDates, dateStr, instance){
			      //...
			  }
		      ],
		      onClose: function(selectedDates, dateStr, instance){
			  // ...
			  alert('onclose');
		      }
		  });
    

    
    // flatpickr('.concert_date', {
	// enableTime: true,
	// plugins: [
	//     new confirmDatePlugin({})
	// ]
    // })
});		
