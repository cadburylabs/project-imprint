define('n/suitescript-ui/spa/manage/reducer/LogsReducer', [
	'n/ui/classes/app/Reducer',
	'n/ui/classes/immutable/ImmutableObject',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function (
	Reducer,
	ImmutableObject,
	StateProps
) {
	'use strict';

	var CONSTANTS = {
		LOG_COUNT: StateProps.LOGS.FIELDS.LOG_COUNT,
		LOG_LIST: StateProps.LOGS.FIELDS.LOG_LIST,
		SCRIPT_OWNER: StateProps.ERROR_NOTIFICATIONS.FIELDS.SCRIPT_OWNER,
		STATUS: StateProps.LOGS.FIELDS.STATUS
	};

	var LogsReducer = Reducer.create({
		name: 'LogsReducer',
		initialState: {
			logCount: 0,
			logList: [],
			status: StateProps.LOGS.STATUS.IDLE
		},

		Action: {
			LOGS_RETRIEVED: function (state, logs) {
				var newState = ImmutableObject.set(state, CONSTANTS.LOG_COUNT, logs.count);
				newState =  ImmutableObject.set(newState, CONSTANTS.STATUS, StateProps.LOGS.STATUS.IDLE);
				return ImmutableObject.set(newState,CONSTANTS.LOG_LIST, logs.items);
			},
			LOADING: function (state){
				return ImmutableObject.set(state,CONSTANTS.STATUS, StateProps.LOGS.STATUS.LOADING);
			},
			ERROR: function (state){
				var newState =  ImmutableObject.set(state, CONSTANTS.LOG_LIST, []);
				return ImmutableObject.set(newState,CONSTANTS.STATUS, StateProps.LOGS.STATUS.ERROR);
			}
		}
	});

	return LogsReducer;
});