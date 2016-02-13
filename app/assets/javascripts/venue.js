function remove_staff_member(link) {
	$(link).prev("input[type=hidden]").val("true");
	$(link).closest(".staff_member").hide();
}

