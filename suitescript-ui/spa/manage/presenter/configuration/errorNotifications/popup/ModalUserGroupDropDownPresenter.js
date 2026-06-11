define('n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/popup/ModalUserGroupDropDownPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/Service',
	'n/ui/widgets/data/ArrayDataSource',
	'n/ui/widgets/toolkit/Dropdown',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/ComponentWithHelp',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/reducer/ErrorNotificationsModalReducer'
], function (
	Class,
	Object,
	Presenter,
	Service,
	ArrayDataSource,
	Dropdown,
	TranslationKeys,
	ComponentWithHelp,
	Constants,
	ErrorNotificationsModalReducer
) {
	'use strict';

	var ModalUserGroupDropDownPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ModalUserGroupDropDownPresenter
		 * @extends Presenter
		 */
		initialize: function ModalUserGroupDropDownPresenter(options) {
			ModalUserGroupDropDownPresenter.$super.call(this, options);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends ModalUserGroupDropDownPresenter# */
		properties: {},

		/** @lends ModalUserGroupDropDownPresenter# */
		methods: {
			_createDropDown: function () {
				this._userGroupsDropDown = new Dropdown({
					valueMember: 'id',
					displayMember: 'value',
					selectedValue: this.state.manage.spa.errorNotifications.userGroupId,
					allowEmpty: true,
					automationId: AutomationIds.GROUP_DROPDOWN,
					dataSource: new ArrayDataSource(this.state.manage.errorNotificationsModal.userGroups)
				});

				this._userGroupsDropDown.on(Dropdown.Event.SELECTED_ITEM_CHANGED, this._dropDownSelectionChanged.bind(this));
				return this._userGroupsDropDown;
			},
			_refreshDropDownDataSource: function (userGroups) {
				if (this._userGroupsDropDown !== null) {
					this._userGroupsDropDown.dataSource = new ArrayDataSource(userGroups);
				}
			},
			_dropDownSelectionChanged: function (args) {
				var selectedId = null;
				if (args.currentItem !== null) {
					selectedId = args.currentItem.id;
				}
				this.dispatchAction(ErrorNotificationsModalReducer.Action.SET_USER_GROUP_ID, selectedId);
			},
			_setSelectedDropDownValue: function (userGroupId) {
				if (this._userGroupsDropDown !== null) {
					this._userGroupsDropDown.select({value: userGroupId});
				}
			}
		},

		/** @lends ModalUserGroupDropDownPresenter# */
		overrides: {
			_onCreateView: function () {
				return new ComponentWithHelp({
					component: this._createDropDown(),
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_MODAL_FIELD_GROUP),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_ERROR_NOTIFICATIONS_USER_GROUP,
					labelPlacement: ComponentWithHelp.labelPlacement.TOP,
					automationId: AutomationIds.GROUP_LABEL,
					type: ComponentWithHelp.TYPE.LABEL
				});
			},
			_onStateChanged: function (old, current) {
				if (old.manage.errorNotificationsModal.userGroups !== current.manage.errorNotificationsModal.userGroups) {
					this._refreshDropDownDataSource(current.manage.errorNotificationsModal.userGroups);

				}
				if (old.manage.errorNotificationsModal.errorNotifications.userGroupId !== current.manage.errorNotificationsModal.errorNotifications.userGroupId) {
					this._setSelectedDropDownValue(current.manage.errorNotificationsModal.errorNotifications.userGroupId);
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				GROUP_LABEL: "manage-spa-configuration-error-notifications-modal-group-label",
				GROUP_DROPDOWN: "manage-spa-configuration-error-notifications-modal-group-dropdown"
			})
		}
	});

	var AutomationIds = ModalUserGroupDropDownPresenter.AutomationIds;
	return ModalUserGroupDropDownPresenter;
});