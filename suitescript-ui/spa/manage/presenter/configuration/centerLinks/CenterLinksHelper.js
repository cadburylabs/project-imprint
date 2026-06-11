define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/CenterLinksHelper', [
	'n/ui/classes/Object'
], function (
	Object
) {
	'use strict';

	var CenterLinksHelper = Object.freeze({
		getLinkLocation: function (linkDetails) {
			if (linkDetails.center.value === ''
			|| linkDetails.section.value === ''
			|| linkDetails.category.value === '') {
				return '';
			}
			return  linkDetails.center.value + Constants.SEPARATOR_CHAR
				+ linkDetails.section.value + Constants.SEPARATOR_CHAR
				+ linkDetails.category.value;
		},
		getLinkSectionLocation: function (linkDetails) {
			return linkDetails.section.value + Constants.SEPARATOR_CHAR
				+ linkDetails.category.value + Constants.SEPARATOR_CHAR
				+ linkDetails.label;
		}
	});

	var Constants = Object.freeze({
		SEPARATOR_CHAR: " > "
	})

	return CenterLinksHelper;
});
