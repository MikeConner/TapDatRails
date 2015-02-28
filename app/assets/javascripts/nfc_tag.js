function remove_payload(link) {
	$(link).prev("input[type=hidden]").val("true");
	$(link).closest(".payload").hide();
}
