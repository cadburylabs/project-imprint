define('n/suitescript-ui/spa/RouteList', [
	'n/ui/compounds/routing/Router',
	'n/suitescript-ui/spa/reducer/RouterReducer'
], function (
	Router,
	RouterReducer
) {
	'use strict';

	var RouteList = {
		LIST: Router.createRoute('#/list', function (args) {
			args.context.dispatchAction(RouterReducer.Action.LIST_ACCESSED);
		}),
		MANAGE: Router.createRoute('#/manage/:id', function (args) {
			args.router.redirectTo(RouteList.MANAGE_BASIC_INFO, args.params);
		}),
		MANAGE_BASIC_INFO: Router.createRoute('#/manage/:id/basic-info', function (args) {
			args.context.dispatchAction(RouterReducer.Action.MANAGE_BASIC_INFO_ACCESSED, args.params.id);
		}),
		MANAGE_CONFIGURATION: Router.createRoute('#/manage/:id/configuration', function (args) {
			args.context.dispatchAction(RouterReducer.Action.MANAGE_CONFIGURATION_ACCESSED, args.params.id);
		}),
		MANAGE_LOGS: Router.createRoute('#/manage/:id/logs', function (args) {
			args.context.dispatchAction(RouterReducer.Action.MANAGE_LOGS_ACCESSED, args.params.id);
		}),
		MANAGE_AUDIT_TRAIL: Router.createRoute('#/manage/:id/audittrail', function (args) {
			args.context.dispatchAction(RouterReducer.Action.MANAGE_AUDIT_TRAIL_ACCESSED, args.params.id);
		}),
		DEFAULT: Router.createRoute('*', function (args) {
			args.router.redirectTo(RouteList.LIST);
		})
	};

	return RouteList;
});
