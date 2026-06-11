define('n/suitescript-ui/spa/manage/reducer/CenterLinkModalReducer', [
	'n/ui/classes/Object',
	'n/ui/classes/app/Reducer',
	'n/ui/classes/immutable/ImmutableObject',
	'n/suitescript-ui/spa/manage/TranslationKeys'
], function (
	Object,
	Reducer,
	ImmutableObject,
	TranslationKeys
) {
	'use strict';

	var Constants = Object.freeze({
		locationPrototype: {
			center: {id: '', value: ''},
			section: {id: '', value: ''},
			category: {id: '', value: ''}
		},
		errorPrototype: {
			isTranslated: true,
			message: ''
		},
		insertBeforePrototype: {id: '', value: ''}
	});
	var CenterLinkModalReducer = Reducer.create({
		name: 'CenterLinkModalReducer',

		initialState: {
			linkId: '',
			originalSelection: {
				location: Constants.locationPrototype,
				linkLabel: '',
				insertBefore: Constants.insertBeforePrototype
			},
			location: Constants.locationPrototype,
			locationError: Constants.errorPrototype,
			linkLabel: '',
			linkLabelError: Constants.errorPrototype,
			insertBefore: Constants.insertBeforePrototype,
			insertBeforeError: Constants.errorPrototype
		},

		Action: {
			SET_ORIGINAL_SELECTION: function (state, originalSelection) {
				var newState = ImmutableObject.set(CenterLinkModalReducer.initialState, 'originalSelection', originalSelection);
				newState = ImmutableObject.set(newState, 'location', originalSelection.location);
				newState = ImmutableObject.set(newState, 'linkLabel', originalSelection.linkLabel);
				newState = ImmutableObject.set(newState, 'insertBefore', originalSelection.insertBefore);
				newState = ImmutableObject.set(newState, 'linkId', originalSelection.linkId);

				return newState;
			},
			SET_LOCATION: function (state, location) {
				var newState = ImmutableObject.set(state, 'location', location);
				var errorMessage = Constants.errorPrototype;
				if (location.category.id != state.originalSelection.location.category.id
					&& location.category.id == '') {
					errorMessage = {
						isTranslated: false,
						message: TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_LOCATION_MANDATORY
					};
				}
				newState = ImmutableObject.set(newState, 'locationError', errorMessage);

				if (state.location.category.id != location.category.id) {
					newState = ImmutableObject.set(newState, 'insertBefore', Constants.insertBeforePrototype);
				}

				return newState;
			},
			SET_ERROR: function (state, error) {
				return ImmutableObject.set(state, error.field, {
					isTranslated: error.isTranslated,
					message: error.message
				});
			},
			SET_LINK_LABEL: function (state, linkLabel) {
				var newState = ImmutableObject.set(state, 'linkLabel', linkLabel);
				var errorMessage = Constants.errorPrototype;
				if (linkLabel != state.originalSelection.linkLabel
					&& linkLabel == '') {
					errorMessage = {
						isTranslated: false,
						message: TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_LINK_LABEL_MANDATORY
					};
				}
				newState = ImmutableObject.set(newState, 'linkLabelError', errorMessage);
				return newState;
			},
			SET_INSERT_BEFORE: function (state, insertBefore) {
				var newValue = Object.extend({}, Constants.insertBeforePrototype, insertBefore);
				return ImmutableObject.set(state, 'insertBefore', newValue);
			}
		}
	});

	return CenterLinkModalReducer;
});