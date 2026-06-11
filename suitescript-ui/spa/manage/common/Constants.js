define('n/suitescript-ui/spa/manage/common/Constants', [
	'n/ui/classes/Object'
], function (
	Object
) {
	var Constants = Object.freeze({
		NOT_PUBLISHED: 'NOT_PUBLISHED',
		FLH: {
			PARENT_ID: 'spa',
			FIELD: {
				SPA_NAME: 'spa_name',
				SPA_ID: 'spa_id',
				SPA_DESCRIPTION: 'spa_description',
				SPA_OWNER: 'spa_owner',
				SPA_URL: 'spa_url',
				SPA_UIF_USAGE: 'uif_usage',
				SPA_SUITEAPP: 'spa_suiteapp',
				SPA_SUITEAPP_ID: 'spa_suiteapp_id',
				SPA_SUITEAPP_PUBLISHER_ID: 'spa_publisher_id',
				SPA_ASSETS: 'spa_assets',
				SPA_FOLDER: 'spa_folder',
				SPA_CLIENT_SCRIPT: 'spa_client_script',
				SPA_SERVER_SCRIPT: 'spa_server_script',
				SPA_EXECUTE_AS: 'spa_execute_as',
				SPA_LOG_LEVEL: 'spa_log_level',
				SPA_AUDIENCE_ALL_ROLES: 'spa_aud_all_roles',
				SPA_LINK_LOCATION: 'spa_link_location',
				SPA_LINK_LABEL: 'spa_link_label',
				SPA_LINK_INSERT_BEFORE: 'spa_link_insert_before',
				SPA_ERROR_NOTIFICATIONS_OWNER: 'spa_notify_owner',
				SPA_ERROR_NOTIFICATIONS_CURRENT_USER: 'spa_notify_user',
				SPA_ERROR_NOTIFICATIONS_ADMINS: 'spa_notify_admins',
				SPA_ERROR_NOTIFICATIONS_USER_GROUP: 'spa_notify_group',
				SPA_ERROR_NOTIFICATIONS_EMAILS: 'spa_notify_emails',
			}
		},
		SUITE_SCRIPT_PERMISSION_KEY: 'ADMI_CUSTOMSCRIPT',
	});

	return Constants;
});