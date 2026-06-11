define('n/suitescript-ui/spa/list/reducer/SpaGridReducer', [
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/classes/app/Reducer'
], function (
	ImmutableObject,
	Reducer
) {
	'use strict';

	var SpaGridReducer = Reducer.create({
		initialState: {
			spaList: []
		},

		Action: {
			SET_SPA_LIST: function (state, spaList) {
				return ImmutableObject.set(state,'spaList', spaList);
			}
		}
	});

	return SpaGridReducer;
});