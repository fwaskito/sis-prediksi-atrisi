/*
jQuery(document).ready(function()
{
	jQuery("#delayrow").hide();
	window.setTimeout("jQuery('#delayrow').show()",5000);
});*/

$(document).ready(function(){
    $("#messageModal").modal('show');
});


$(document).ready(function (){

	var table = $('#example').DataTable({
		dom: 'Bfrtip',
		buttons: ['csv', 'excel', 'pdf']
	});

    // Handle click on "Expand All" button
	$('#btn-show-all-children').on('click', function(){
        // Expand row details
		table.rows(':not(.parent)').nodes().to$().find('td:first-child').trigger('click');
	});

    // Handle click on "Collapse All" button
	$('#btn-hide-all-children').on('click', function(){
        // Collapse row details
		table.rows('.parent').nodes().to$().find('td:first-child').trigger('click');
	});

	const theButton = document.querySelector(".button");

	theButton.addEventListener("click", () => {
		theButton.classList.add("button--loading");
	});	

});
