define('n/suitescript-ui/spa/service/UrlQueryParam',
	[
		'n/ui/classes/Object'
	],
	function (
		Object
	) {
		'use strict';

		var UrlQueryParam = Object.freeze({
			PAGE_SIZE: 'pagesize',
			PAGE_NUMBER: 'pagenumber',
			DEPLOYMENT_KEY: 'deploymentkey',
			SERVER_SCRIPT_KEY: 'serverscriptkey',
			SCRIPT_ID: 'scriptid'
		});

		return UrlQueryParam;
	});