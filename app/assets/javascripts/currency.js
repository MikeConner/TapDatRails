function remove_denomination(link) {
	$(link).prev("input[type=hidden]").val("true");
	$(link).closest(".denomination").hide();
}

function remove_generator(link) {
	$(link).prev("input[type=hidden]").val("true");
	$(link).closest(".generator").hide();
}
