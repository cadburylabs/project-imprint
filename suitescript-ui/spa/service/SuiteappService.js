define('n/suitescript-ui/spa/service/SuiteappService', [
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

	var SuiteappService = Class.create({
		initialize: function SpaService(context) {
			this._context = context.context;
			this._httpProxyService = this._context.services.get(ServiceList.HTTP_PROXY_SERVICE);
		},
		methods: {
			getSuiteAppList: function () {
				return this._httpProxyService.get(ResourcePaths.SUITEAPP.RESOURCE(), null, HttpProxyService.OPTIONS.DEFAULT);
			}
		}
	});

	return SuiteappService;
});