define('n/suitescript-ui/spa/service/UserService', [
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

	var ScriptRecordService = Class.create({
		initialize: function SpaService(context) {
			this._context = context.context;
			this._httpProxyService = this._context.services.get(ServiceList.HTTP_PROXY_SERVICE);
		},
		methods: {
			getOwnerList: function (serverScriptKey) {
				return this._httpProxyService.get(ResourcePaths.USER.RESOURCE(serverScriptKey), null, HttpProxyService.OPTIONS.DEFAULT);
			}
		}
	});

	return ScriptRecordService;
});
