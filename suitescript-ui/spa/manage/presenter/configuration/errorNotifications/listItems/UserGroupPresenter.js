define('n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/listItems/UserGroupPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/listItems/ItemComponent'
], function (
	Class,
	Object,
	Presenter,
	ItemComponent
) {
	'use strict';

	var UserGroupPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class UserGroupPresenter
		 * @extends Presenter
		 */
		initialize: function UserGroupPresenter(options) {
			UserGroupPresenter.$super.call(this, options);
		},

		/** @lends UserGroupPresenter# */
		properties: {},

		/** @lends UserGroupPresenter# */
		methods: {
			_retrieveUserGroupName: function () {
				var userGroupId = this.state.manage.spa.errorNotifications.userGroupId;
				var userGroups = this.state.manage.errorNotificationsModal.userGroups;
				if (userGroupId !== null && userGroups.length > 0) {
					this._userGroupItem.labelName = userGroups.find(function (userGroup) {
						return userGroup.id === userGroupId
					}).value;
					this._userGroupItem.visible = true;
					return;
				}
				this._userGroupItem.labelName = '';
				this._userGroupItem.visible = false;
			}
		},

		/** @lends UserGroupPresenter# */
		overrides: {
			_onCreateView: function () {
				this._userGroupItem = new ItemComponent({
					labelName: '',
					automationId: AutomationIds.USER_GROUP,
					visible: false
				});
				this._retrieveUserGroupName();
				return this._userGroupItem;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.errorNotificationsModal.userGroups !== current.manage.errorNotificationsModal.userGroups) {
					this._retrieveUserGroupName();
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				USER_GROUP: "manage-spa-configuration-error-notifications-display-group-label"
			})
		}
	});

	var AutomationIds = UserGroupPresenter.AutomationIds;
	return UserGroupPresenter;
});