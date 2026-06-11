define('n/suitescript-ui/spa/service/RolesService', [
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

	const ADMIN_ROLE_VALUE = "3";

	function removeAdminRole(roleList) {
		return roleList.filter(function (role) {return role.id !== ADMIN_ROLE_VALUE});
	}

	function setCurrentRole(roleList) {
		return roleList.map(function (role) {
			if (role.id === '') {
				role.id = null;
			}
			return role;
		});
	}

	function adaptRoleList(roleList) {
		return setCurrentRole(removeAdminRole(roleList));
	}

	function removeCurrentRole(roleList) {
		return roleList.filter(function(role) {return role.id !== ""});
	}

	const RolesService = Class.create({
		initialize: function SpaService(context) {
			this._context = context.context;
			this._httpProxyService = this._context.services.get(ServiceList.HTTP_PROXY_SERVICE);
		},
		methods: {
			getExecuteAsRoleList: function (deploymentKey) {
				return this._httpProxyService.get(ResourcePaths.EXECUTION_ROLE.RESOURCE(deploymentKey), null, HttpProxyService.OPTIONS.DEFAULT)
					.then(function (result) {
						return adaptRoleList(result.response);
					});
			},
			getAudienceRoleList: function (deploymentKey) {
				return this._httpProxyService.get(ResourcePaths.AUDIENCE_ROLE.RESOURCE(deploymentKey), null, HttpProxyService.OPTIONS.DEFAULT)
					.then(function (result) {
						return removeCurrentRole(result.response);
					});
			}
		}
	});

	return RolesService;
});
