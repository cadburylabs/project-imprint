define('n/suitescript-ui/spa/manage/reducer/BasicInfoReducer', [
	'n/ui/classes/app/Reducer',
	'n/ui/classes/immutable/ImmutableObject'
], function (
	Reducer,
	ImmutableObject
) {
	'use strict';

	return Reducer.create({
		name: 'BasicInfoReducer',

		initialState: {
			suiteappList: []
		},

		Action: {
			SET_SUITEAPP: function (state, suiteappList) {
				return ImmutableObject.set(state, 'suiteappList', suiteappList);
			}
		}
	});
});