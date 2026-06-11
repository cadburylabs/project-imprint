define('n/suitescript-ui/spa/manage/reducer/SpaAudienceReducer', [
	'n/ui/classes/Object',
	'n/ui/classes/app/Reducer',
	'n/ui/classes/immutable/ImmutableObject',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function (
	Object,
	Reducer,
	ImmutableObject,
	StateProps
) {
	'use strict';

	const rolesAudience = Object.freeze({
		allRoles: false,
		roles: []
	});

	const filterByExternal = function(state, isExternal) {
		return state.static.allRolesAvailable
			.filter(role => state.editing.roles.roles.includes(parseInt(role.id)) && isExternal === role.external)
			.map(({id}) => parseInt(id));
	}

	return Reducer.create({
		name: 'SpaAudienceReducer',

		initialState: {
			original: {
				roles: Object.copy(rolesAudience)
			},
			editing: {
				roles: Object.copy(rolesAudience)
			},
			static: {
				allRolesAvailable: []
			},
			state: 'initial'
		},

		Action: {
			AUDIENCE_RECEIVED: function (state, roleList) {
				//TODO manage empty response?
				const newState = ImmutableObject.set(state, ['original', 'roles'], roleList);
				return ImmutableObject.set(newState, ['editing', 'roles'], roleList);
			},
			ALL_ROLES_TOGGLED: function (state, value) {
				let newState = ImmutableObject.set(state, ['editing', 'roles', 'allRoles'], value);
				if (value) {
					const remainingExternal = filterByExternal(state, true);
					newState = ImmutableObject.set(newState, ['editing', 'roles', 'roles'], remainingExternal);
				}
				return newState;
			},
			AVAILABLE_ROLES_RECEIVED: function (state, allRolesAvailable) {
				return ImmutableObject.set(state, ['static', 'allRolesAvailable'], allRolesAvailable);
			},
			SELECTED_INTERNAL_ROLES_CHANGED: function (state, selectedRoles) {
				const externalRoles =  filterByExternal(state, true);
				const newRoles = [...externalRoles, ...selectedRoles];

				return ImmutableObject.set(state, ['editing', 'roles', 'roles'], newRoles);
			},
			SELECTED_EXTERNAL_ROLES_CHANGED: function (state, selectedRoles) {
				const internalRoles =  filterByExternal(state,false);
				const newRoles = [...internalRoles, ...selectedRoles];

				return ImmutableObject.set(state, ['editing', 'roles', 'roles'], newRoles);
			},
			SETUP_AUDIENCE_BUTTON_CLICKED: function (state) {
				const newState = ImmutableObject.set(state, 'editing', Object.copy(state.original));
				return ImmutableObject.set(newState, 'state', StateProps.SPA.AUDIENCE.STATE.EDITING);
			},
			CANCEL_EDIT_BUTTON_CLICKED: function (state) {
				const newState = ImmutableObject.set(state, 'editing', Object.copy(state.original));
				return ImmutableObject.set(newState, 'state', StateProps.SPA.AUDIENCE.STATE.IDLE);
			},
			SAVE_EDIT_BUTTON_CLICKED: function (state) {
				return ImmutableObject.set(state, 'state', StateProps.SPA.AUDIENCE.STATE.SAVING);
			},
			SAVE_FINISHED_SUCCESFULLY: function (state) {
				const newState = ImmutableObject.set(state, ['original', 'roles'], state.editing.roles);
				return ImmutableObject.set(newState, 'state', StateProps.SPA.AUDIENCE.STATE.IDLE);
			},
			SAVE_UPDATE_FAILED: function (state) {
				return ImmutableObject.set(state, 'state', StateProps.SPA.AUDIENCE.STATE.EDITING);
			}
		}
	});
});