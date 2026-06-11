define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/CenterLinkModal', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/widgets/toolkit/Button',
	'n/ui/widgets/toolkit/Modal',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/CenterLinkModalSaveButtonPresenter'
], function (
	Class,
	Object,
	Button,
	Modal,
	TranslationKeys,
	CenterLinkModalSaveButtonPresenter
) {
	'use strict';

	var CenterLinkModal = Class.create({
		/**
		 * @class CenterLinkModal
		 *
		 * @param {Object} options
		 * @param {Button} options.owner
		 * @param {Presenter} options.contentPresenter
		 * @param {LinkModalSaveButtonPresenter} options.saveButtonPresenter
		 * @param {I18n} options.translationService
		 */
		initialize: function (options) {
			this.owner = options.owner;
			this._translationService = options.translationService;
			this._content = options.contentPresenter;
			this._buttonSave = options.saveButtonPresenter;
			this._create();
		},

		properties: {},

		methods: {
			_create: function () {
				this._modal = new Modal({
					owner: this.owner,
					size: Modal.Size.LARGE,
					title: this._translationService.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_TITLE),
					ariaLabel: this._translationService.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_TITLE),
					content: this._content.createView(),
					buttons: this._createButtons()
				});
			},
			_closeModal: function () {
				this._modal.close();
				this._content.dispose();
				this._buttonSave.dispose();
				this._buttonCancel.dispose();
			},
			_createButtons: function () {
				this._buttonCancel = new Button({
					automationId: AutomationIds.CANCEL_BUTTON,
					ariaLabel: this._translationService.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_CANCEL_BUTTON),
					label: this._translationService.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_CANCEL_BUTTON),
					action: this._closeModal.bind(this)
				});

				this._buttonSave.on(CenterLinkModalSaveButtonPresenter.Event.LINK_SAVED, this._closeModal.bind(this));

				return [this._buttonSave.createView(), this._buttonCancel];
			},
			open: function () {
				this._modal.open();
			}
		},
		static: {
			AutomationIds: Object.freeze({
				CANCEL_BUTTON: "manage-spa-configuration-center-link-modal-button-cancel"
			})
		}
	});

	var AutomationIds = CenterLinkModal.AutomationIds;

	return CenterLinkModal;
});