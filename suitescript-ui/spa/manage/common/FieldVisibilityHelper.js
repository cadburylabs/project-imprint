define('n/suitescript-ui/spa/manage/common/FieldVisibilityHelper',
	[
		'n/ui/classes/Class',
		'n/suitescript-ui/spa/manage/common/Constants'
	],
	function (
		Class,
		Constants
	) {
		'use strict';

		var FieldVisibilityHelper = Class.create({
			static: {
				isEditable: function (spa) {
					return spa.type === Constants.NOT_PUBLISHED && !spa.locked;
				}
			}
		});

		return FieldVisibilityHelper;

	});
