define('n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/popup/ModalContentPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/Service',
	'n/ui/widgets/toolkit/CheckBox',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/Text',
	'n/ui/widgets/toolkit/layout/GapSize',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/ComponentWithHelp',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/popup/ModalEmailAddressPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/popup/ModalUserGroupDropDownPresenter',
	'n/suitescript-ui/spa/manage/reducer/ErrorNotificationsModalReducer',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function (
	Class,
	Object,
	Presenter,
	Service,
	CheckBox,
	StackPanel,
	Text,
	GapSize,
	TranslationKeys,
	ComponentWithHelp,
	Constants,
	ModalEmailAddressPresenter,
	ModalUserGroupDropDownPresenter,
	ErrorNotificationsModalReducer,
	StateProps
) {
	'use strict';

	var ModalContentPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ModalContentPresenter
		 * @extends Presenter
		 */
		initialize: function ModalContentPresenter(options) {
			ModalContentPresenter.$super.call(this, options);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends ModalContentPresenter# */
		properties: {},

		/** @lends ModalContentPresenter# */
		methods: {
			_createHeader: function () {
				return new Text({
					text: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_MODAL_CONTENT_TEXT),
					automationId: AutomationIds.MODAL_CONTENT_TEXT,
					whitespace: true
				});
			},
			_createCurrentUserCheckBox: function () {
				this._currentUserCheckBox = new CheckBox({
					automationId: AutomationIds.CURRENT_USER_CHECKBOX,
					value: this.state.manage.spa.errorNotifications.currentUser,
					on: {
						toggled: this._toggleCheckBox.bind(this, ErrorNotificationsModalReducer.Action.SET_CURRENT_USER)
					}
				});

				return new ComponentWithHelp({
					component: this._currentUserCheckBox,
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_MODAL_FIELD_CURRENT_USER),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_ERROR_NOTIFICATIONS_CURRENT_USER
				});
			},
			_createScriptOwnerCheckBox: function () {
				this._scriptOwnerCheckBox = new CheckBox({
					automationId: AutomationIds.SCRIPT_OWNER_CHECKBOX,
					value: this.state.manage.spa.errorNotifications.scriptOwner,
					on: {
						toggled: this._toggleCheckBox.bind(this, ErrorNotificationsModalReducer.Action.SET_SCRIPT_OWNER)
					}
				});

				return new ComponentWithHelp({
					component: this._scriptOwnerCheckBox,
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_MODAL_FIELD_SCRIPT_OWNER),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_ERROR_NOTIFICATIONS_OWNER
				});
			},
			_createAllAdminsCheckBox: function () {
				this._allAdminsCheckBox = new CheckBox({
					automationId: AutomationIds.ALL_ADMINS_CHECKBOX,
					value: this.state.manage.spa.errorNotifications.allAdmins,
					on: {
						toggled: this._toggleCheckBox.bind(this, ErrorNotificationsModalReducer.Action.SET_ALL_ADMINS)
					}
				});

				return new ComponentWithHelp({
					component: this._allAdminsCheckBox,
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_MODAL_FIELD_ALL_ADMINS),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_ERROR_NOTIFICATIONS_ADMINS
				});
			},
			_toggleCheckBox: function (action, args) {
				this.context.dispatchAction(action, args.currentToggle);
			},
			_createGroupDropDown: function () {
				return this._createChild(ModalUserGroupDropDownPresenter).createView();
			},
			_createEmailTextArea: function () {
				return this._createChild(ModalEmailAddressPresenter).createView();

			},
			_updateContent: function () {
				this._errorNotificationsPanel.clear();
				this._errorNotificationsPanel.add(this._createHeader());
				this._errorNotificationsPanel.add(this._createCurrentUserCheckBox());
				this._errorNotificationsPanel.add(this._createScriptOwnerCheckBox());
				this._errorNotificationsPanel.add(this._createAllAdminsCheckBox());
				this._errorNotificationsPanel.add(this._createGroupDropDown());
				this._errorNotificationsPanel.add(this._createEmailTextArea());
			}
		},

		/** @lends ModalContentPresenter# */
		overrides: {
			_onCreateView: function () {
				this._errorNotificationsPanel = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL,
					itemGap: GapSize.MEDIUM,
					outerGap: GapSize.MEDIUM,
					alignment: StackPanel.Alignment.START,
					justification: StackPanel.Justification.START
				});
				return this._errorNotificationsPanel;
			},
			_onStateChanged: function (old, current) {
				if (!Object.equals(old.manage.spa.errorNotifications, current.manage.spa.errorNotifications)) {
					this._updateContent();
				}
				if(old.manage.errorNotificationsModal.status !== current.manage.errorNotificationsModal.status
					&& current.manage.errorNotificationsModal.status === StateProps.ERROR_NOTIFICATIONS.STATUS.MODAL_OPENED){
					this._updateContent();
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				MODAL_CONTENT_TEXT: "manage-spa-configuration-error-notifications-modal-content-text",
				CURRENT_USER_CHECKBOX: "manage-spa-configuration-error-notifications-modal-content-current-user-checkbox",
				SCRIPT_OWNER_CHECKBOX: "manage-spa-configuration-error-notifications-modal-content-script-owner-checkbox",
				ALL_ADMINS_CHECKBOX: "manage-spa-configuration-error-notifications-modal-content-all-admins-checkbox"
			})
		}
	});

	var AutomationIds = ModalContentPresenter.AutomationIds;

	return ModalContentPresenter;
});