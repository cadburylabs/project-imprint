define('n/suitescript-ui/spa/reducer/MainReducer', [
	'n/ui/classes/app/Reducer',
	'n/suitescript-ui/spa/list/reducer/SpaGridReducer',
	'n/suitescript-ui/spa/manage/reducer/ManageMainReducer',
	'n/suitescript-ui/spa/reducer/RouterReducer'
], function (
	Reducer,
	SpaGridReducer,
	ManageMainReducer,
	RouterReducer
) {
	'use strict';

	var MainReducer = Reducer.create({
		initialState: {
			manage: ManageMainReducer.initialState,
			list: SpaGridReducer.initialState,
			router: RouterReducer.initialState
		},
		Action: {},
		after: [{
			path: 'manage',
			reduce: ManageMainReducer
		},{
			path: 'list',
			reduce: SpaGridReducer
		},{
			path: 'router',
			reduce: RouterReducer
		}]
	});

	return MainReducer;
});
