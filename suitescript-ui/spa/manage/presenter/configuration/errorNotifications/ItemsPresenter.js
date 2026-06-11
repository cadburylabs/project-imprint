define('n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/ItemsPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/listItems/ItemComponent',
	'n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/listItems/UserGroupPresenter'
], function (
	Class,
	Object,
	Presenter,
	StackPanel,
	ItemComponent,
	UserGroupPresenter
) {
	'use strict';

	var ItemsPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ItemsPresenter
		 * @extends Presenter
		 */
		initialize: function ItemsPresenter(options) {
			ItemsPresenter.$super.call(this, options);
		},

		/** @lends ItemsPresenter# */
		properties: {},

		/** @lends ItemsPresenter# */
		methods: {
			_populateErrorNotificationItems: function () {
				this._errorNotificationItemsList.clear();
				this._errorNotificationItemsList.add(this._getErrorNotificationItems());
			},
			_getErrorNotificationItems: function () {
				this.errorNotificationItems = [];
				this._addCurrentUser();
				this._addScriptOwner();
				this._addAllAdmins();
				this._addUserGroups();
				this._addEmailItems();
				return this.errorNotificationItems;
			},
			_addCurrentUser: function () {
				this.state.manage.spa.errorNotifications.currentUser && this.errorNotificationItems.push(
					new ItemComponent({
						labelName: Constants.CURRENT_USER,
						automationId: AutomationIds.CURRENT_USER
					}));
			},
			_addScriptOwner: function () {
				this.state.manage.spa.errorNotifications.scriptOwner && this.errorNotificationItems.push(
					new ItemComponent({
						labelName: Constants.SCRIPT_OWNER,
						automationId: AutomationIds.SCRIPT_OWNER
					}));
			},
			_addAllAdmins: function () {
				this.state.manage.spa.errorNotifications.allAdmins && this.errorNotificationItems.push(
					new ItemComponent({
						labelName: Constants.ALL_ADMINS,
						automationId: AutomationIds.ALL_ADMINS
					}));
			},
			_addUserGroups: function () {
				this.state.manage.spa.errorNotifications.userGroupId !== null
				&& this.errorNotificationItems.push(this._createChild(UserGroupPresenter).createView());
			},
			_addEmailItems: function () {
				var that = this;
				var emails = this.state.manage.spa.errorNotifications.emails;
				emails.forEach(this._addEmail.bind(this));
			},
			_addEmail: function (emailAddress) {
				this.errorNotificationItems.push(
					new ItemComponent({
						labelName: emailAddress,
						automationId: AutomationIds.EMAIL + '-' + emailAddress
					}));
			}
		},

		/** @lends ItemsPresenter# */
		overrides: {
			_onCreateView: function () {
				this._errorNotificationItemsList = new StackPanel({
					wrap: true,
					orientation: StackPanel.Orientation.HORIZONTAL
				});
				this._populateErrorNotificationItems();
				return this._errorNotificationItemsList;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.spa.errorNotifications !== current.manage.spa.errorNotifications) {
					this._populateErrorNotificationItems();
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				CURRENT_USER: "manage-spa-configuration-error-notifications-display-current-user-label",
				SCRIPT_OWNER: "manage-spa-configuration-error-notifications-display-script-owner-label",
				ALL_ADMINS: "manage-spa-configuration-error-notifications-display-all-admins-label",
				EMAIL: "manage-spa-configuration-error-notifications-display-email-label"

			}),
			Constants: Object.freeze({
				CURRENT_USER: "Current user",
				SCRIPT_OWNER: "Script owner",
				ALL_ADMINS: "All admins"
			})
		}
	});

	var AutomationIds = ItemsPresenter.AutomationIds;
	var Constants = ItemsPresenter.Constants;

	return ItemsPresenter;
});