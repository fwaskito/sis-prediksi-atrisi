
$(document).ready(function(){
	$('[data-toggle="tooltip"]').tooltip();
	var actions = $("table td:last-child").html();
/** 	
// Append table with add row form on add new button click
	$("#add-new").click(function(){
		$(this).attr("disabled", "disabled");
		var index = $("table tbody tr:last-child").index();
		var row = '<tr>' +
		'<td><input type="text" class="form-control" name="id" id="txtname"></td>' +
		'<td><input type="text" class="form-control" name="name" id="txtdepartment"></td>' +
		'<td><input type="text" class="form-control" name="department" id="txtphone"></td>' +
		'<td><input type="text" class="form-control" name="dist" id="txtphone"></td>' +
		'<td>' + actions + '</td>' +
		'</tr>';
		$("table").append(row);  
		$("table tbody tr").eq(index + 1).find(".edit, .delete").toggle();
		$('[data-toggle="tooltip"]').tooltip();

	});

// Add row on add button click
	$(document).on("click", ".add", function(){
		var empty = false;
		var input = $(this).parents("tr").find('input[type="text"]');
		input.each(function(){
			if(!$(this).val()){
				$(this).addClass("error");
				empty = true;
			} else{
				$(this).removeClass("error");
			}
		});
		var txtname = $("#txtname").val();
		var txtdepartment = $("#txtdepartment").val();
		var txtphone = $("#txtphone").val();
		$.post("/ajax_add", { txtname: txtname, txtdepartment: txtdepartment, txtphone: txtphone}, function(data) {
			$("#displaymessage").html(data);
			$("#displaymessage").show();
		});
		$(this).parents("tr").find(".error").first().focus();
		if(!empty){
			input.each(function(){
				$(this).parent("td").html($(this).val());
			});   
			$(this).parents("tr").find(".add, .edit").toggle();
			$(".add-new").removeAttr("disabled");
		} 
	});
*/
// Delete row on delete button click
	$(document).on("click", ".delete", function(){
		$(this).parents("tr").remove();
		$(".add-new").removeAttr("disabled");
		var id = $(this).attr("id");
		var string = id;
		$.post("/ajax_delete", { string: string}, function(data) {
			$("#displaymessage").html(data);
			$("#displaymessage").show();
		});
	});
// update rec row on edit button click
	$(document).on("click", ".update", function(){
		var id = $(this).attr("id");
		var string = id;
		var txtname = $("#txtname").val();
		var txtdepartment = $("#txtdepartment").val();
		var txtphone = $("#txtphone").val();
		$.post("/ajax_update", { string: string,txtname: txtname, txtdepartment: txtdepartment, txtphone: txtphone}, function(data) {
			$("#displaymessage").html(data);
			$("#displaymessage").show();
		});


	});
// Edit row on edit button click
	$(document).on("click", ".edit", function(){  
		$(this).parents("tr").find("td:not(:last-child)").each(function(i){
			if (i=='0'){
				var idname = 'txtname';
			}else if (i=='1'){
				var idname = 'txtdepartment';
			}else if (i=='2'){
				var idname = 'txtphone';
			}else{} 
			$(this).html('<input type="text" name="updaterec" id="' + idname + '" class="form-control" value="' + $(this).text() + '">');
		});  
		$(this).parents("tr").find(".add, .edit").toggle();
		$(".add-new").attr("disabled", "disabled");
		$(this).parents("tr").find(".add").removeClass("add").addClass("update"); 
	});
});

