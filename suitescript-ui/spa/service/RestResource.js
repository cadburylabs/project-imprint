define('n/suitescript-ui/spa/service/RestResource',
	[
		'n/ui/classes/Object'
	],
	function (
		Object
	) {
		'use strict';

		var RestResource = Object.freeze({
			SPA: 'spa',
			LOG: 'log',
			LINK: 'link',
			CENTER: 'center',
			CATEGORY: 'category',
			USER: 'user',
			SUITEAPP: 'suiteapp',
			LOGLEVEL: 'loglevel',
			EXECUTIONROLE: 'executionrole',
			AUDIENCEROLE: 'audiencerole',
			ERROR_NOTIFICATION: 'errornotification',
			AUDIENCE: 'audience',
			USER_GROUP: 'usergroup'
		});

		return RestResource;
	});