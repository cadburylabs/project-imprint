define('n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/SetupNotificationsButtonPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/Button',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/popup/ModalPresenter',
	'n/suitescript-ui/spa/manage/reducer/ErrorNotificationsModalReducer',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function (
	Class,
	Object,
	Presenter,
	Button,
	TranslationKeys,
	ModalPresenter,
	ErrorNotificationsModalReducer,
	StateProps
) {
	'use strict';

	var SetupNotificationsButtonPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class SetupNotificationsButtonPresenter
		 * @extends Presenter
		 */
		initialize: function SetupNotificationsButtonPresenter(options) {
			SetupNotificationsButtonPresenter.$super.call(this, options);
		},

		/** @lends SetupNotificationsButtonPresenter# */
		properties: {},

		/** @lends SetupNotificationsButtonPresenter# */
		methods: {
			_createSetupNotificationButton: function () {
				this._button = new Button({
					automationId: AutomationIds.SETUP_NOTIFICATIONS_BUTTON,
					ariaLabel: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_SETUP_NOTIFICATIONS_BUTTON),
					type: Button.Type.GHOST,
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_SETUP_NOTIFICATIONS_BUTTON),
					size: Button.Size.SMALL,
					action: this._setUpNotificationsButtonClicked.bind(this)
				});
				return this._button;
			},
			_createModal: function () {
				this._notificiationsSettingModal = new ModalPresenter ({context: this.context.createChild(), owner:this._button}).createView();
			},
			_setUpNotificationsButtonClicked: function (args) {
				this.dispatchAction(ErrorNotificationsModalReducer.Action.SETUP_NOTIFICATIONS_BUTTTON_CLICKED, this.state.manage.spa.errorNotifications);
			},
			_modalOpened: function () {
				if(!this._notificiationsSettingModal.active) this._notificiationsSettingModal.open();

			}
		},

		/** @lends SetupNotificationsButtonPresenter# */
		overrides: {
			_onCreateView: function() {
				var setupNotificationsButton = this._createSetupNotificationButton();
				this._createModal();
				return setupNotificationsButton;
			},
			_onStateChanged: function (oldState, currentState) {
				if (currentState.manage.errorNotificationsModal.status === StateProps.ERROR_NOTIFICATIONS.STATUS.MODAL_OPENED) {
					this._modalOpened();
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				SETUP_NOTIFICATIONS_BUTTON: "manage-spa-configuration-error-notifications-setup-notifications-button"
			})
		}
	});

	var AutomationIds = SetupNotificationsButtonPresenter.AutomationIds;

	return SetupNotificationsButtonPresenter;
});