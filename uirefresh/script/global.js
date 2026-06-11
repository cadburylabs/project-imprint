/*
 * Copyright © 2025, Oracle and/or its affiliates.
 */

var NS = window.NS || {};
window.NS = NS;
NS.UI = NS.UI || {};
NS.UI.Helpers = NS.UI.Helpers || {};

NS.UI.Refresh = {};

NS.UI.Constants = {
	TOOLBAR_APPEAR_TIMEOUT: 150,
	TOOLBAR_APPEAR_ANIMATION: 500,
	TOOLBAR_ORIGIN_TOP: 0,
	TOOLTIP_ARROW_HEIGHT: 10,
	TOOLTIP_ALIGN: {
		TOP_LEFT: 0,
		TOP_RIGHT: 1,
		BOTTOM_LEFT: 2,
		BOTTOM_RIGHT: 3,
		CENTER_SCREEN: 4
	},
	TOOLTIP_ALIGN_DEFAULT: 1,

	LOADER_DEFAULT_SIZE: 128,

	GLOBALSEARCH_DELAY: 700,
	GLOBALSEARCH_MAX_ITEMS: 10,
	GLOBALSEARCH_BUTTONAREA_WIDTH: 50,

	MENU_ITEM_HEIGHT: 40,
	MENU_SHADOW_SIZE: 3,
	MENU_SCROLL_SPEED_MAX: 800,
	MENU_OPEN_TIMEOUT: 300,
	MENU_HOVER_TIMEOUT: 200,
	MENU_CLOSE_TIMEOUT: 400,

	KeyCode: {
		BACKSPACE: 8,
		TAB: 9,
		ENTER: 13,
		SHIFT: 16,
		CTRL: 17,
		ALT: 18,
		ESCAPE: 27,
		SPACE: 32,
		PAGE_UP: 33,
		PAGE_DOWN: 34,
		END: 35,
		HOME: 36,
		ARROW_LEFT: 37,
		ARROW_UP: 38,
		ARROW_RIGHT: 39,
		ARROW_DOWN: 40,
		INSERT: 45,
		DELETE: 46,
		NUMBER_0: 48,
		NUMBER_9: 57,
		A: 65,
		Z: 90,
		NUMPAD_0: 96,
		NUMPAD_9: 105,

		forChar: function (chr) {
			return chr.charCodeAt(0);
		}
	}
};

NS.UI.Refresh.moveLabel = function moveLabel(labelFieldName, destinationFieldName) {
	var $label = NS.jQuery('#' + labelFieldName + '_lbl'),
		$destination = NS.jQuery('#' + destinationFieldName);

	$destination.closest('.uir-field-wrapper').children('.uir-label').each(function () {
		var $child = NS.jQuery(this);
		$child.removeClass("uir-label-empty");
		$label.show();
		$child.html($label);
	});
};

/**
 * Shows loader animation over targeted element.
 * Usage: var loader = new uir_loader('#my_div', 128); loader.close();
 * @param target selector string or jQuery or DOM
 * @param size Size of preloader image: 16, 32, 64, 128. Can be skipped to auto-detect size.
 */
NS.UI.Helpers.uir_loader = function uir_loader(target, size) {
	var SIZES = [16, 32, 64, 128];

	if (!size || SIZES.indexOf(size) == -1) {
		size = 0; // default
	}

	var $target = NS.jQuery(target);
	var oldStyle = $target.attr('style');
	var height = $target.height();
	var width = $target.width();

	if (size == 0) {
		// Fallback
		size = SIZES[0];

		var minDimension = Math.min(width, height);
		for (var i = 0; i < SIZES.length; i++) {
			if (SIZES[i] <= minDimension) {
				size = SIZES[i];
			} else {
				break;
			}
		}
	}

	$target
		.css({height: height, width: width})
		.addClass('uir-loader')
		.addClass('loading-' + size.toString());

	NS.jQuery('<div class="loader"></div>')
		.css('top', height / 2 - size / 2)
		.appendTo($target);


	this.close = function () {
		$target
			.attr('style', oldStyle)
			.removeClass('uir-loader')
			.removeClass('loading-' + size.toString());

		$target
			.find('.loader')
			.remove();

	}
};

NS.UI.Helpers.preventDefault = function (e) {
	e = e || window.event;
	if (e.preventDefault) {
		e.preventDefault();
	}
	e.returnValue = false;
};

/**
 * Scrollbar width varies between browsers and can potentially change.
 * Use this function to get the scrollbar width instead of hardcoding px size
 */
NS.UI.Helpers.scrollbarWidth = function () {
	// first time, calculate size of scrollbar
	var scrollDiv = document.createElement("div");
	scrollDiv.style.width = "100px";
	scrollDiv.style.height = "100px";
	scrollDiv.style.overflow = "scroll";
	document.body.appendChild(scrollDiv);
	var scrollbarWidth = scrollDiv.offsetWidth - scrollDiv.clientWidth;
	document.body.removeChild(scrollDiv);

	// overwrite it so that it only returns the value instead of calculating each time
	NS.UI.Helpers.scrollbarWidth = function () {return scrollbarWidth;};

	return NS.UI.Helpers.scrollbarWidth();
};

NS.UI.Helpers.getClosestAncestorFromClass = function (elem, name) {
	var result = null;

	if (!!elem) {
		while (elem.className.indexOf(name) == -1 && elem != document.body) {
			elem = elem.parentElement;
		}
		if (elem.className.indexOf(name) > -1) {
			result = elem;
		}
	}

	return result;
};

NS.UI.Helpers.Accessibility = NS.UI.Helpers.Accessibility || {};
NS.UI.Helpers.Accessibility.doClickOnSpaceKey = function (elem) {
	var $elem = NS.jQuery(elem);
	$elem.keydown(function (event) {
		if (event.which === NS.UI.Constants.KeyCode.SPACE) {
			NS.jQuery(this).click();
			event.preventDefault();
		}
	});
};

NS.UI.Helpers.WindowMessage = NS.UI.Helpers.WindowMessage || {};
NS.UI.Helpers.WindowMessage.send = function (payload) {
	window.postMessage({type: 'nsn-message', payload});
}

NS.UI.Helpers.WindowMessage.Event = {
	PORTLET_MAXIMIZED: 'portlet-maximized',
	PORTLET_MINIMIZED: 'portlet-minimized',
};

/**
 * Device feature detection
 */
NS.Device = NS.Device || {};
NS.Device.hasTouchSupport = ('ontouchstart' in window) || (navigator.maxTouchPoints > 0) || (navigator.msMaxTouchPoints > 0);
NS.Device.hasPointerEnabled = window.navigator.pointerEnabled || window.navigator.msPointerEnabled;
var ua = navigator.userAgent;
NS.Device.isIOS = /iPad/i.test(ua) || /iPhone/i.test(ua);

if (NS.Device.hasTouchSupport) {
	NS.jQuery(function () {
		NS.jQuery(document.body).addClass('uir-touch-support');
	});
}

if (NS.Device.isIOS) {
	NS.jQuery('html').css({
		'cursor': 'pointer',
		'-webkit-tap-highlight-color': 'rgba(0,0,0,0)'
	});
}

(function (NS) {
	var isReady = false;
	NS.UI.ready = function (callback) {
		if (isReady) {
			setTimeout(callback, 0);
		} else {
			var executed = false;
			var onReady = function () {
				if (!executed) {
					isReady = true;
					executed = true;
					callback();
				}
			};
			NS.jQuery(document).ready(onReady);
			NS.jQuery(window).on('load', onReady);
		}
	};
})(NS);

NS.jQuery(document).ready(function () {
	const pageCategory = document.body.getAttribute('data-page-category');
	if (pageCategory === 'list' || pageCategory === 'dashboard') {
		NS.UI.List.initialize();
	} else if (pageCategory === 'form') {
		NS.UI.Form.initialize();
	}
});
