define('n/suitescript-ui/spa/manage/common/PermissionHelper', [
	'n/ui/classes/Class',
	'N/runtime',
	'n/suitescript-ui/spa/manage/common/Constants'
], function (
	Class,
	runtime,
	Constants
) {
	'use strict';

	function getPermissionLevel() {
		return runtime.getCurrentUser().getPermission({name: Constants.SUITE_SCRIPT_PERMISSION_KEY});
	}

	var PermissionHelper = Class.create({
		static: {
			userHasEditPermission: function () {
				return getPermissionLevel() >= runtime.Permission.EDIT;
			},
			userHasFullPermission: function () {
				return getPermissionLevel() >= runtime.Permission.FULL;
			}
		}
	});

	return PermissionHelper;
});
