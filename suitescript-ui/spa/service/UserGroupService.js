define('n/suitescript-ui/spa/service/UserGroupService', [
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

	var UserGroupService = Class.create({
		initialize: function SpaService(context) {
			this._context = context.context;
			this._httpProxyService = this._context.services.get(ServiceList.HTTP_PROXY_SERVICE);
		},
		methods: {
			getUserGroups: function (scriptId) {
				return this._httpProxyService.get(ResourcePaths.USER_GROUP.RESOURCE(scriptId), null, HttpProxyService.OPTIONS.DEFAULT);
			}
		}
	});

	return UserGroupService;
});