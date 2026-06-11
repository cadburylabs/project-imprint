define('n/suitescript-ui/spa/manage/reducer/ErrorNotificationsModalReducer', [
	'n/ui/classes/app/Reducer',
	'n/ui/classes/immutable/ImmutableObject',
	'n/suitescript-ui/spa/manage/common/EmailValidator',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function (
	Reducer,
	ImmutableObject,
	EmailValidator,
	StateProps
) {
	'use strict';

	var CONSTANTS = {
		ERROR_NOTIFICATIONS: StateProps.ERROR_NOTIFICATIONS.FIELDS.ERROR_NOTIFICATIONS,
		USER_GROUPS: StateProps.ERROR_NOTIFICATIONS.FIELDS.USER_GROUPS,
		CURRENT_USER: StateProps.ERROR_NOTIFICATIONS.FIELDS.CURRENT_USER,
		SCRIPT_OWNER: StateProps.ERROR_NOTIFICATIONS.FIELDS.SCRIPT_OWNER,
		ALL_ADMINS: StateProps.ERROR_NOTIFICATIONS.FIELDS.ALL_ADMINS,
		USER_GROUP_ID: StateProps.ERROR_NOTIFICATIONS.FIELDS.USER_GROUP_ID,
		EMAILS: StateProps.ERROR_NOTIFICATIONS.FIELDS.EMAILS,
		EMAIL_ERROR: StateProps.ERROR_NOTIFICATIONS.FIELDS.EMAIL_ERROR,
		STATUS: StateProps.ERROR_NOTIFICATIONS.FIELDS.STATUS
	};

	var ErrorNotificationsModalReducer = Reducer.create({
		name: 'ErrorNotificationsModalReducer',

		initialState: {
			userGroups: [],
			errorNotifications: {
				currentUser: false,
				scriptOwner: false,
				allAdmins: false,
				userGroupId: null,
				emails: [],
				emailError: false
			},
			status: StateProps.ERROR_NOTIFICATIONS.IDLE
		},

		Action: {
			SETUP_NOTIFICATIONS_BUTTTON_CLICKED: function (state,value) {
				var newState = ImmutableObject.set(state, CONSTANTS.ERROR_NOTIFICATIONS, value);
				newState = ImmutableObject.set(newState, [CONSTANTS.ERROR_NOTIFICATIONS, CONSTANTS.EMAIL_ERROR], false);
				return ImmutableObject.set(newState, CONSTANTS.STATUS, StateProps.ERROR_NOTIFICATIONS.STATUS.MODAL_OPENED);
				},
			MODAL_CLOSED: function (state) { return ImmutableObject.set(state, CONSTANTS.STATUS, StateProps.ERROR_NOTIFICATIONS.STATUS.MODAL_CLOSED);},
			SET_USER_GROUPS: function (state, userGroups) { return ImmutableObject.set(state, CONSTANTS.USER_GROUPS, userGroups);},
			SET_CURRENT_USER: function (state, value) { return ImmutableObject.set(state, [CONSTANTS.ERROR_NOTIFICATIONS, CONSTANTS.CURRENT_USER], value);},
			SET_SCRIPT_OWNER: function (state, value) { return ImmutableObject.set(state, [CONSTANTS.ERROR_NOTIFICATIONS, CONSTANTS.SCRIPT_OWNER], value);},
			SET_ALL_ADMINS: function (state, value) { return ImmutableObject.set(state, [CONSTANTS.ERROR_NOTIFICATIONS, CONSTANTS.ALL_ADMINS], value);},
			SET_USER_GROUP_ID: function (state, value) { return ImmutableObject.set(state, [CONSTANTS.ERROR_NOTIFICATIONS, CONSTANTS.USER_GROUP_ID], value);},
			SET_EMAIL_ADDRESS: function (state, emails) {
				if (_emailsAreInvalid(emails)) {
					return ImmutableObject.set(state, [CONSTANTS.ERROR_NOTIFICATIONS, CONSTANTS.EMAIL_ERROR], true);
				}
				var newState = ImmutableObject.set(state, [CONSTANTS.ERROR_NOTIFICATIONS, CONSTANTS.EMAIL_ERROR], false);
				newState = ImmutableObject.set(newState, [CONSTANTS.ERROR_NOTIFICATIONS, CONSTANTS.EMAILS], emails);
				return newState;
			},
			SET_EMAIL_ERROR: function (state, value) { return ImmutableObject.set(state, [CONSTANTS.ERROR_NOTIFICATIONS, CONSTANTS.EMAIL_ERROR], value);},
			SAVE_FAILED : function (state) { return ImmutableObject.set(state, CONSTANTS.STATUS, StateProps.ERROR_NOTIFICATIONS.STATUS.SAVE_FAILED);}
		}
	});

	function _emailsAreInvalid(emails){
		return emails.length !== 0 && !EmailValidator.emailsAreValid(emails);
	}

	return ErrorNotificationsModalReducer;
});