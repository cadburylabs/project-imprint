define('n/suitescript-ui/spa/service/LogLevelsService', [
	'n/ui/classes/Class',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/service/HttpProxyService',
	'n/suitescript-ui/spa/service/ResourcePaths'
], function (
	Class,
	ServiceList,
	HttpProxyService,
	ResourcePaths
) {
	'use strict';

	var LogLevelsService = Class.create({
		initialize: function SpaService(context) {
			this._context = context.context;
			this._httpProxyService = this._context.services.get(ServiceList.HTTP_PROXY_SERVICE);
		},
		methods: {
			getLogLevelList: function (scriptRecordId) {
				return this._httpProxyService.get(ResourcePaths.LOGLEVEL.RESOURCE(scriptRecordId), null,  HttpProxyService.OPTIONS.DEFAULT);
			}
		}
	});

	return LogLevelsService;
});
