/*
 * Copyright © 2026, Oracle and/or its affiliates.
 */

define('n/ui/form/Service', [
	'n/ui/classes/Object',
	'n/ui/webcore/Service'
], function (Object, Service) {
	'use strict';

	return Object.extend({}, Service, {
		ACTION_SERVICE: 'actionService',
		PAGE_SEARCH: 'pageSearch',
		USER_MESSAGE_SERVICE: 'userMessageService',
		TRANSLATION_SERVICE: 'translationService',
		PERSONALIZATION: 'personalizationService',
	});
});
