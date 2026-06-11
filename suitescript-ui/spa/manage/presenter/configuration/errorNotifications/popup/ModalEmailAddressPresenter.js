define('n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/popup/ModalEmailAddressPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/Service',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Image',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/TextBox',
	'n/ui/widgets/tooltip/Tooltip',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/ComponentWithHelp',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/reducer/ErrorNotificationsModalReducer'
], function (
	Class,
	Object,
	Presenter,
	Service,
	SystemIcon,
	Image,
	StackPanel,
	TextBox,
	Tooltip,
	TranslationKeys,
	ComponentWithHelp,
	Constants,
	ErrorNotificationsModalReducer
) {
	'use strict';

	var ModalEmailAddressPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ModalEmailAddressPresenter
		 * @extends Presenter
		 */
		initialize: function ModalEmailAddressPresenter(options) {
			ModalEmailAddressPresenter.$super.call(this, options);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends ModalEmailAddressPresenter# */
		properties: {},

		/** @lends ModalEmailAddressPresenter# */
		methods: {
			_createEmailTextBoxArea: function () {
				this._emailTextBoxArea = new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					alignment: StackPanel.Alignment.CENTER,
					justification: StackPanel.Justification.START,
					items: [this._emailTextBox(), this._errorComponent()]
				});
				return this._emailTextBoxArea;
			},
			_emailTextBox: function () {
				this._emailTextBox = new TextBox({
					text: this.state.manage.spa.errorNotifications.emails.join(','),
					automationId: AutomationIds.EMAIL_ADDRESS_TEXTBOX,
					ariaLabel: AutomationIds.EMAIL_ADDRESS_TEXTBOX,
					inputSize: PresenterConstants.TEXT_BOX_SIZE
				});
				this._emailTextBox.on(TextBox.Event.TEXT_ACCEPTED, this._emailAddressTextBoxChanged.bind(this));
				return this._emailTextBox;
			},
			updateEmailTextBox: function () {
				this._emailTextBox.text = this.state.manage.spa.errorNotifications.emails.join(',');
			},
			_errorComponent: function () {
				this._errorTooltip = new Tooltip({
					closeStrategy: Tooltip.CloseStrategy.focusedOrOver(),
					automationId: AutomationIds.EMAIL_ADDRESS_ERROR_TOOLTIP,
					content: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_MODAL_SPECIFIC_EMAILS_VALIDATION)
				});

				this._errorComponent = new Image({
					image: SystemIcon.ERROR.withCaption(this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_MODAL_SPECIFIC_EMAILS_VALIDATION)),
					tooltip: this._errorTooltip,
					automationId: AutomationIds.EMAIL_ADDRESS_ERROR_ICON,
					ariaLabel: AutomationIds.EMAIL_ADDRESS_ERROR_ICON,
					classList: [CssClass.ERROR_COMPONENT],
					visible: false
				});

				return this._errorComponent;

			},
			_emailAddressTextBoxChanged: function (args) {
				var emailAddressText = args.currentText;
				//Remove all whitespace
				emailAddressText = emailAddressText.replace(/\s+/g, '');
				var emailAddressList = [];
				if (emailAddressText !== '') {
					emailAddressList = emailAddressText.split(',');
				}
				this.dispatchAction(ErrorNotificationsModalReducer.Action.SET_EMAIL_ADDRESS, emailAddressList);
			},
			_displayError: function (emailError) {
				this._emailTextBox.valid = !emailError;
				this._errorComponent.visible = emailError;
			}
		},

		/** @lends ModalEmailAddressPresenter# */
		overrides: {
			_onCreateView: function () {
				return new ComponentWithHelp({
					component: this._createEmailTextBoxArea(),
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_MODAL_FIELD_SPECIFIC_EMAILS),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_ERROR_NOTIFICATIONS_EMAILS,
					labelPlacement: ComponentWithHelp.labelPlacement.TOP,
					automationId: AutomationIds.EMAIL_ADDRESS_LABEL,
					type: ComponentWithHelp.TYPE.LABEL
				});
			},
			_onStateChanged: function (old, current) {
				if (old.manage.errorNotificationsModal.errorNotifications.emailError !== current.manage.errorNotificationsModal.errorNotifications.emailError) {
					this._displayError(current.manage.errorNotificationsModal.errorNotifications.emailError);
				}
			}
		},
		static: {
			CssClass: Object.freeze({
				ERROR_COMPONENT: 'n-ssui-spa-manage-error-component'
			}),
			Constants: Object.freeze({
				TEXT_BOX_SIZE: 60
			}),
			AutomationIds: Object.freeze({
				EMAIL_ADDRESS_TEXTBOX: "manage-spa-configuration-error-notifications-modal-email-address-field",
				EMAIL_ADDRESS_LABEL: "manage-spa-configuration-error-notifications-modal-email-address-label",
				EMAIL_ADDRESS_ERROR_TOOLTIP: "manage-spa-configuration-error-notifications-modal-email-address-error-tooltip",
				EMAIL_ADDRESS_ERROR_ICON: "manage-spa-configuration-error-notifications-modal-email-address-error-icon"
			})
		}
	});

	var CssClass = ModalEmailAddressPresenter.CssClass;
	var PresenterConstants = ModalEmailAddressPresenter.Constants;
	var AutomationIds = ModalEmailAddressPresenter.AutomationIds;
	return ModalEmailAddressPresenter;
});