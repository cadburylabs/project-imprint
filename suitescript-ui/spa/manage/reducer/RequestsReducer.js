define('n/suitescript-ui/spa/manage/reducer/RequestsReducer', [
	'n/ui/classes/app/Reducer',
	'n/ui/classes/immutable/ImmutableObject'
],function (
	Reducer,
	ImmutableObject
) {
	'use strict';

	var RequestsReducer = Reducer.create({
		name: 'RequestsReducer',

		initialState: {
			spaDetails: {
				id: '',
				status: ''
			}
		},

		Action: {
			REQUEST_STARTED: function (state, payload) {
				var newState = ImmutableObject.set(state, [payload.key, "id"], payload.id);
				return ImmutableObject.set(newState, [payload.key, "status"], "idle");
			},
			REQUEST_COMPLETED: function (state, payload) {
				var newState = ImmutableObject.set(state, [payload.key, "id"], payload.id);
				return ImmutableObject.set(newState, [payload.key, "status"], payload.status);
			}
		}
	});

	return RequestsReducer;
});