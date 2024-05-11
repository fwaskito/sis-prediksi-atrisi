
$(document).ready(function(){
    $("#messageModal").modal('show');
});

$(document).ready(function (){

	var table = $('#example').DataTable({
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
});


$(document).ready(function(){
	$(".btn").click(function(){
		$("#").modal('show');
	});
});


