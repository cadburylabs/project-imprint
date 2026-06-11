define('n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/popup/ModalPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/Button',
	'n/ui/widgets/toolkit/Modal',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/popup/ModalContentPresenter',
	'n/suitescript-ui/spa/manage/reducer/ErrorNotificationsModalReducer',
	'n/suitescript-ui/spa/manage/reducer/ManageMainReducer',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function (
	Class,
	Object,
	Presenter,
	Button,
	Modal,
	ServiceList,
	TranslationKeys,
	ModalContentPresenter,
	ErrorNotificationsModalReducer,
	ManageMainReducer,
	StateProps
) {
	'use strict';

	var ModalPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ModalPresenter
		 * @extends Presenter
		 */
		initialize: function ModalPresenter(options) {
			ModalPresenter.$super.call(this, options);
			this._spaService = this.context.services.get(ServiceList.SPA);
			this._owner = options.owner;
		},

		/** @lends ModalPresenter# */
		properties: {},

		/** @lends ModalPresenter# */
		methods: {
			_createNotificationSettingsModal: function () {
				this._notificiationsSettingModal = new Modal({
					automationId: AutomationIds.MODAL,
					owner: this._owner,
					size: Modal.Size.MEDIUM,
					title: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_MODAL_TITLE),
					ariaLabel: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_MODAL_TITLE),
					content: this._createModalContent(),
					buttons: this._createModalActionButtons(),
					buttonsJustification: Modal.ButtonsJustification.LEFT,
					on: {closed: this._cancelClicked.bind(this)}
				});

				return this._notificiationsSettingModal
			},
			_createModalContent: function () {
				return this._createChild(ModalContentPresenter).createView();
			},
			_createModalActionButtons: function () {
				this._modalButtonSave = new Button({
					automationId: AutomationIds.MODAL_SAVE_BUTTON,
					hierarchy: Button.Hierarchy.PRIMARY,
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_MODAL_SAVE_BUTTON),
					action: this._saveClicked.bind(this),
					enabled: !this.state.manage.errorNotificationsModal.errorNotifications.emailError
				});
				this._modalButtonCancel = new Button({
					automationId: AutomationIds.MODAL_CANCEL_BUTTON,
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_MODAL_CANCEL_BUTTON),
					action: this._cancelClicked.bind(this)
				});

				return [this._modalButtonSave, this._modalButtonCancel];
			},
			_setSaveButtonVisibility: function (isEnabled) {
				this._modalButtonSave.enabled = isEnabled;
			},
			_saveClicked: function () {
				this._setSaveButtonVisibility(false);
				this._saveErrorNotications();

			},
			_cancelClicked: function () {
				//Don't dispatch action when its saved successfully
				if(this.state.manage.errorNotificationsModal.status !== StateProps.ERROR_NOTIFICATIONS.STATUS.SAVE_SUCCESS){
					this.dispatchAction(ErrorNotificationsModalReducer.Action.MODAL_CLOSED);
				}
			},
			_saveErrorNotications: function () {
				var errorNotificationPayload = {
					currentUser: this.state.manage.errorNotificationsModal.errorNotifications.currentUser,
					scriptOwner: this.state.manage.errorNotificationsModal.errorNotifications.scriptOwner,
					allAdmins: this.state.manage.errorNotificationsModal.errorNotifications.allAdmins,
					userGroupId: this.state.manage.errorNotificationsModal.errorNotifications.userGroupId,
					emails: this.state.manage.errorNotificationsModal.errorNotifications.emails
				};

				this._spaService.updateErrorNotifications(this.state.manage.spa.id, errorNotificationPayload)
					.then(this._saveSuccessful.bind(this, errorNotificationPayload))
					.catch(this._saveFailed.bind(this))
			},
			_saveSuccessful: function (errorNotificationsPayload, response) {
				this.dispatchAction(ManageMainReducer.Action.ERROR_NOTIFICATIONS_SAVED, errorNotificationsPayload);
			},
			_saveFailed: function () {
				this.dispatchAction(ErrorNotificationsModalReducer.Action.SAVE_FAILED);
			},
			_onSaveSuccess: function () {
				this._onModalClosed();
			},
			_onSaveFailed: function () {
				this._setSaveButtonVisibility(true);
			},
			_onModalOpened: function () {
				this._setSaveButtonVisibility(true);
			},
			_onModalClosed: function () {
				this._notificiationsSettingModal.close();
			},
			_updatePresenterAfterStatusChange: function (status) {
				var methodForAction = this._statusChangeActions[status];
				if (methodForAction === undefined) throw 'state not supported';
				methodForAction();
			},
			_initialiseStatusActions: function () {
				this._statusChangeActions = [];
				this._statusChangeActions[StateProps.ERROR_NOTIFICATIONS.STATUS.MODAL_OPENED] = this._onModalOpened.bind(this);
				this._statusChangeActions[StateProps.ERROR_NOTIFICATIONS.STATUS.MODAL_CLOSED] = this._onModalClosed.bind(this);
				this._statusChangeActions[StateProps.ERROR_NOTIFICATIONS.STATUS.SAVE_SUCCESS] = this._onSaveSuccess.bind(this);
				this._statusChangeActions[StateProps.ERROR_NOTIFICATIONS.STATUS.SAVE_FAILED] = this._onSaveFailed.bind(this);
			}
		},

		/** @lends ModalPresenter# */
		overrides: {
			_onCreateView: function () {
				this._initialiseStatusActions();
				return this._createNotificationSettingsModal();
			},
			_onStateChanged: function (old, current) {
				if (old.manage.errorNotificationsModal.errorNotifications.emailError !== current.manage.errorNotificationsModal.errorNotifications.emailError) {
					this._setSaveButtonVisibility(!current.manage.errorNotificationsModal.errorNotifications.emailError);
				}
				if (old.manage.errorNotificationsModal.status !== current.manage.errorNotificationsModal.status) {
					this._updatePresenterAfterStatusChange(current.manage.errorNotificationsModal.status);
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				MODAL_SAVE_BUTTON: "manage-spa-configuration-error-notifications-setup-notifications-modal-save-button",
				MODAL_CANCEL_BUTTON: "manage-spa-configuration-error-notifications-setup-notifications-modal-cancel-button"
			})
		}
	});

	var AutomationIds = ModalPresenter.AutomationIds;

	return ModalPresenter;
});