define('n/suitescript-ui/spa/manage/reducer/StateProps', [
	'n/ui/classes/Object'
], function (
	Object
) {
	var StateProps = Object.freeze({
		SPA: Object.freeze({
			NAME: 'name',
			EXECUTE_AS_ROLE: 'executeAsRoleId',
			LOG_LEVEL: 'logLevelId',
			DESCRIPTION: 'description',
			URL: 'url',
			ID: 'id',
			OWNER: 'ownerId',
			USES_UIF: 'usesUif',
			AUDIENCE: {
				STATE: {
					IDLE: 'idle',
					EDITING: 'editing',
					SAVING: 'saving'
				}
			}
		}),
		ERROR_NOTIFICATIONS:Object.freeze({
			FIELDS: {
				ERROR_NOTIFICATIONS: 'errorNotifications',
				USER_GROUPS: 'userGroups',
				CURRENT_USER: 'currentUser',
				SCRIPT_OWNER: 'scriptOwner',
				ALL_ADMINS: 'allAdmins',
				USER_GROUP_ID: 'userGroupId',
				EMAILS: 'emails',
				EMAIL_ERROR: 'emailError',
				STATUS: 'status'
			},
			STATUS: {
				MODAL_OPENED: 'modalOpened',
				MODAL_CLOSED: 'modalClosed',
				SAVE_SUCCESS: 'saveSuccess',
				SAVE_FAILED: 'saveFailed',
				IDLE: 'idle'
			}
		}),
		LOGS:Object.freeze({
			FIELDS: {
				LOG_COUNT: 'logCount',
				LOG_LIST: 'logList',
				STATUS: 'status'
			},
			STATUS: {
				IDLE: 'idle',
				LOADING: 'loading',
				ERROR: 'error'
			}
		}),
		ROUTER: Object.freeze({
			PAGE: 'page',
			TAB: 'tab',
			ID: 'id'
		})
	});

	return StateProps;
});
