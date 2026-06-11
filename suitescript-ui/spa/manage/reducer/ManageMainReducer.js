define('n/suitescript-ui/spa/manage/reducer/ManageMainReducer', [
	'n/ui/classes/Object',
	'n/ui/classes/app/Reducer',
	'n/ui/classes/immutable/ImmutableObject',
	'n/suitescript-ui/spa/manage/reducer/BasicInfoReducer',
	'n/suitescript-ui/spa/manage/reducer/CenterLinkDeleteModalReducer',
	'n/suitescript-ui/spa/manage/reducer/CenterLinkModalReducer',
	'n/suitescript-ui/spa/manage/reducer/ErrorNotificationsModalReducer',
	'n/suitescript-ui/spa/manage/reducer/LogsReducer',
	'n/suitescript-ui/spa/manage/reducer/RequestsReducer',
	'n/suitescript-ui/spa/manage/reducer/SpaReducer',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function (
	Object,
	Reducer,
	ImmutableObject,
	BasicInfoReducer,
	CenterLinkDeleteModalReducer,
	CenterLinkModalReducer,
	ErrorNotificationsModalReducer,
	LogsReducer,
	RequestsReducer,
	SpaReducer,
	StateProps
) {
	'use strict';

	var ManageMainReducer = Reducer.create({
		initialState: {
			logs: Object.freeze(LogsReducer.initialState),
			spa: Object.freeze(SpaReducer.initialState),
			basicInfo: Object.freeze(BasicInfoReducer.initialState),
			centerLinkModal: Object.freeze(CenterLinkModalReducer.initialState),
			centerLinkDeleteModal: Object.freeze(CenterLinkDeleteModalReducer.initialState),
			errorNotificationsModal: Object.freeze(ErrorNotificationsModalReducer.initialState),
			notification: '',
			requests: Object.freeze(RequestsReducer.initialState)
		},
		Action: {
			Set_SPA: function (state, payload) {
				// Merge with current spaDetails instead of replacing the whole object
				var newSpaState = Object.extend({}, state.spa, payload);
				return ImmutableObject.set(state, 'spa', newSpaState);
			},
			ADD_BUTTON_CLICKED: function (state, payload) {
				return ImmutableObject.set(state, 'centerLinkModal', Object.freeze(CenterLinkModalReducer.initialState));
			},
			ERROR_NOTIFICATIONS_LOADED: function (state, value) {
				var newState = ImmutableObject.set(state, ['errorNotificationsModal', 'errorNotifications'], value);
				newState = ImmutableObject.set(newState, ['errorNotificationsModal', 'errorNotifications', 'emailError'], false);
				return ImmutableObject.set(newState, ['spa', 'errorNotifications'], value);
			},
			ERROR_NOTIFICATIONS_SAVED: function (state, value) {
				var newState = ImmutableObject.set(state, ['errorNotificationsModal', 'status'], StateProps.ERROR_NOTIFICATIONS.STATUS.SAVE_SUCCESS);
				return ImmutableObject.set(newState, ['spa', 'errorNotifications'], value);
			},
			SET_NOTIFICATION: function (state, value) {
				return ImmutableObject.set(state, 'notification', value);
			}
		},
		after: [{
			path: 'logs',
			reduce: LogsReducer
		}, {
			path: 'spa',
			reduce: SpaReducer
		}, {
			path: 'centerLinkModal',
			reduce: CenterLinkModalReducer
		}, {
			path: 'centerLinkDeleteModal',
			reduce: CenterLinkDeleteModalReducer
		}, {
			path: 'basicInfo',
			reduce: BasicInfoReducer
		}, {
			path: 'errorNotificationsModal',
			reduce: ErrorNotificationsModalReducer
		}, {
			path: 'requests',
			reduce: RequestsReducer
		}
		]
	});

	return ManageMainReducer;
});
