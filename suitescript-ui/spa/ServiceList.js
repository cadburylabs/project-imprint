define('n/suitescript-ui/spa/ServiceList', [
	'n/ui/classes/Object'
], function (
	Object
) {
	'use strict';

	var ServiceList = Object.freeze({
		LOG_LEVELS: 'logLevels',
		ROUTER: 'router',
		ROLES: 'roles',
		USER: 'user',
		SPA: 'spa',
		MESSAGE_DEFINITION: 'messageDefinition',
		LINKS: 'links',
		SUITEAPP: 'suiteapp',
		USER_GROUPS: 'userGroups',
		HTTP_PROXY_SERVICE: 'httpProxyService',
	});

	return ServiceList;
});
