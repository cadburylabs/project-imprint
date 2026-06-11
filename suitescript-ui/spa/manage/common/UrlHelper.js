define('n/suitescript-ui/spa/manage/common/UrlHelper',
	[
		'n/ui/classes/Object'
	],
	function (
		Object
	) {
		'use strict';

		var UrlHelper = {
			getBaseUrl: function () {
				return window.location.origin;
			},
			_getSpaBaseUrl: function (suiteAppId) {
				if (suiteAppId == null) return this.getBaseUrl() + UrlHelper.Constants.SPA_ROUTE;
				else return this.getBaseUrl() + UrlHelper.Constants.SPA_SUITEAPP_ROUTE + suiteAppId + "/";
			},
			getSpaUrl: function (spaUrlName, suiteAppId) {
				return this._getSpaBaseUrl(suiteAppId) + spaUrlName;
			},
			getFolderUrl: function (spaFolderId) {
				var spaFolderUrl = this.getBaseUrl();
				spaFolderUrl += Constants.MEDIA_ITEM_FILE_CABINET_URL;
				spaFolderUrl += spaFolderId;
				spaFolderUrl += Constants.WHENCE_SUFFIX;
				return spaFolderUrl;
			},
			Constants: Object.freeze({
				SPA_ROUTE: "/spa/",
				SPA_SUITEAPP_ROUTE: "/spa-app/",
				MEDIA_ITEM_FILE_CABINET_URL: "/app/common/media/mediaitemfolders.nl?folder=",
				WHENCE_SUFFIX: "&whence="
			})
		};

		var Constants = UrlHelper.Constants;

		return UrlHelper;

	});
