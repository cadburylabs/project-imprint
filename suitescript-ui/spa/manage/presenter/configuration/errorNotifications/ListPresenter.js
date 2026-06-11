define('n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/ListPresenter', [
	'n/ui/classes/Class',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/common/SpinnerComponent',
	'n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/ItemsPresenter',
	'n/suitescript-ui/spa/manage/reducer/ErrorNotificationsModalReducer',
	'n/suitescript-ui/spa/manage/reducer/ManageMainReducer'
], function(
	Class,
	Presenter,
	StackPanel,
	ServiceList,
	SpinnerComponent,
	ItemsPresenter,
	ErrorNotificationsModalReducer,
	ManageMainReducer
)  {
	'use strict';

	var ListPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ListPresenter
		 * @extends Presenter
		 */
		initialize: function ListPresenter(options) {
			ListPresenter.$super.call(this, options);
			this._spaService = this.context.services.get(ServiceList.SPA);
			this._userGroupService = this.context.services.get(ServiceList.USER_GROUPS);
		},

		/** @lends ListPresenter# */
		properties: {},

		/** @lends ListPresenter# */
		methods: {
			_loadErrorNotificationSettings: function (spaId) {
				this._spaService.getErrorNotifications(spaId)
					.then(this._errorNotificationsLoaded.bind(this))
			},
			_loadUserGroups: function (scriptId) {
				this._userGroupService.getUserGroups(scriptId)
					.then(this._userGroupsLoaded.bind(this))
			},
			_errorNotificationsLoaded: function (response) {
				var errorNotifications = response.response;
				this.context.dispatchAction(ManageMainReducer.Action.ERROR_NOTIFICATIONS_LOADED, errorNotifications);
			},
			_userGroupsLoaded: function (response) {
				var userGroups = response.response;
				this.context.dispatchAction(ErrorNotificationsModalReducer.Action.SET_USER_GROUPS, userGroups);
			},
			_updateErrorNotificationSettings: function (errorNotificationSettings) {
				this._setSpinnerVisible(true);
				if (errorNotificationSettings !== undefined) {
					this._errorNotifcationItems.visible = true;
				}
				this._setSpinnerVisible(false);
			},
			_displayErrorNotificationItems: function () {
				this._errorNotifcationItems = this._createChild(ItemsPresenter).createView();
				return this._errorNotifcationItems;
			},
			_setSpinnerVisible: function (value) {
				this._loader.visible = value;
			},
			_createLoader: function () {
				this._loader = SpinnerComponent.new({
					style: {
						width: 'auto',
						height: '120px',
						padding: '2px'
					}
				});
				return this._loader;
			}
		},

		/** @lends ListPresenter# */
		overrides: {
			_onCreateView: function () {
				this._errorNotificationsPanel = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL,
					items: [this._createLoader(), this._displayErrorNotificationItems()]
				});
				this._errorNotifcationItems.visible = false;
				this._setSpinnerVisible(true);
				return this._errorNotificationsPanel;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.spa.errorNotifications !== current.manage.spa.errorNotifications) {
					this._updateErrorNotificationSettings(current.manage.spa.errorNotifications);
				}

				if (old.manage.spa.id !== current.manage.spa.id
					&& current.manage.spa.id !== "") {
					this._loadErrorNotificationSettings(current.manage.spa.id);
				}
				if (old.manage.spa.scriptId !== current.manage.spa.scriptId
					&& current.manage.spa.scriptId !== "") {
					this._loadUserGroups(current.manage.spa.scriptId);

				}
			}
		}
	});

	return ListPresenter;
});