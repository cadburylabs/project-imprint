define('n/suitescript-ui/spa/manage/reducer/CenterLinkDeleteModalReducer', [
	'n/ui/classes/app/Reducer',
	'n/ui/classes/immutable/ImmutableObject'
], function (
	Reducer,
	ImmutableObject
) {
	'use strict';

	var CenterLinkDeleteModalReducer = Reducer.create({
		name: 'CenterLinkDeleteModalReducer',

		initialState: {
			linkId: '',
			saveSuccess: false,
			isSaving: false,
		},

		Action: {
			DELETE_BUTTON_CLICKED: function (state, linkId) {
				var newState = ImmutableObject.set(CenterLinkDeleteModalReducer.initialState, 'linkId', linkId);
				return newState;
			},
			DELETE_CONFIRMATION_BUTTON_CLICKED: function (state) {

				return ImmutableObject.set(state, 'isSaving', true);
			},
			LINK_DELETED_SUCCESS: function (state) {
				var newState = ImmutableObject.set(state, 'saveSuccess', true);
				newState = ImmutableObject.set(newState, 'isSaving', false);

				return newState;
			},
			LINK_DELETE_FAILED: function (state) {
				var newState = ImmutableObject.set(state, 'saveSuccess', false);
				newState = ImmutableObject.set(newState, 'isSaving', false);

				return newState;
			}
		}
	});

	return CenterLinkDeleteModalReducer;
});