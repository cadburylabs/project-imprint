define('n/suitescript-ui/spa/service/LinksService', [
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

	var LinksService = Class.create({
		initialize: function SpaService(context) {
			this._context = context.context;
			this._httpProxyService = this._context.services.get(ServiceList.HTTP_PROXY_SERVICE);
		},
		methods: {
			getCenters: function () {
				return this._httpProxyService.get(ResourcePaths.CENTER.RESOURCE(), null, HttpProxyService.OPTIONS.DEFAULT);
			},
			getCategoryLinks: function (categoryId) {
				return this._httpProxyService.get(ResourcePaths.CATEGORY.SUBRESOURCE.LINK(categoryId), null, HttpProxyService.OPTIONS.DEFAULT);
			}
		}
	});

	return LinksService;
});
