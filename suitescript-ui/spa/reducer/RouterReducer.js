define('n/suitescript-ui/spa/reducer/RouterReducer', [
	'n/ui/classes/app/Reducer',
	'n/ui/classes/immutable/ImmutableObject',
	'n/suitescript-ui/spa/PageList',
	'n/suitescript-ui/spa/manage/Navigation',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function (
	Reducer,
	ImmutableObject,
	PageList,
	Navigation,
	StateProps
) {
	'use strict';

	var initialState = {
		page: '',
		tab: Navigation.BASIC_INFO,
		id: ''
	};

	function newState(page, tab, id){
		var newState = ImmutableObject.set(initialState, StateProps.ROUTER.PAGE, page);
		newState = ImmutableObject.set(newState, StateProps.ROUTER.TAB, tab);
		return  ImmutableObject.set(newState, StateProps.ROUTER.ID, id);
	}

	var RouterReducer = Reducer.create({
		name: 'RouterReducer',

		initialState: initialState,
		Action: {
			LIST_ACCESSED: function (state, value) {
				return ImmutableObject.set(initialState, StateProps.ROUTER.PAGE, PageList.LIST)
			},
			MANAGE_BASIC_INFO_ACCESSED: function (state, id) {
				return newState(PageList.MANAGE, Navigation.BASIC_INFO, id);
			},
			MANAGE_CONFIGURATION_ACCESSED: function (state, id) {
				return newState(PageList.MANAGE, Navigation.CONFIGURATION, id);
			},
			MANAGE_LOGS_ACCESSED: function (state, id) {
				return newState(PageList.MANAGE, Navigation.LOGS, id);
			},
			MANAGE_AUDIT_TRAIL_ACCESSED: function (state, id) {
				return newState(PageList.MANAGE, Navigation.AUDIT_TRAIL, id);
			}
		}
	});

	return RouterReducer;
});