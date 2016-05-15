$(document).ready(function () {

	$(document).attr('data-useragent', navigator.userAgent);

	$('li.menu-icon').hover(function () {

		if ($('span.name:visible').length == 0) {
			$('#menu-titles li').addClass('hidden');
			var id = this.id;
			var txt = (id == "home-icon") ? "home-text" : (id == "blog-icon") ? "blog-text" : (id == "contact-icon") ? "contact-text" : undefined;
			if (txt) {
				$('#' + txt).removeClass('hidden');
				$('#' + id + " i").addClass('icon-active');
			}
		}

	}).mouseleave(function () {
		$('#menu-titles li').addClass('hidden');
		$('li.menu-icon i').removeClass('icon-active');
	});


	if ($('#home-page').length > 0) $('#home-icon').addClass('active');
	if ($('#blog-page').length > 0) $('#blog-icon').addClass('active');
	
});