define('n/suitescript-ui/spa/manage/presenter/basicInfo/actionButtons/DeleteAppButtonPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Button',
	'n/ui/widgets/toolkit/Modal',
	'n/ui/widgets/toolkit/Text',
	'n/suitescript-ui/spa/RouteList',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys'
], function (
	Class,
	Object,
	Presenter,
	SystemIcon,
	Button,
	Modal,
	Text,
	RouteList,
	ServiceList,
	TranslationKeys
) {
	'use strict';

	var DeleteAppButtonPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class DeleteAppButtonPresenter
		 * @extends Presenter
		 */
		initialize: function DeleteAppButtonPresenter(options) {
			DeleteAppButtonPresenter.$super.call(this, options);

			this._spaService = this.context.services.get(ServiceList.SPA);
			this._routerService = this.services.get(ServiceList.ROUTER);
		},

		/** @lends DeleteAppButtonPresenter# */
		properties: {},

		/** @lends DeleteAppButtonPresenter# */
		methods: {
			_createModalContent: function () {
				this._contentMessage = new Text({
					automationId: AutomationIds.MODAL_CONTENT,
					text: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_BUTTON_DELETE_MODAL_CONTENT),
					wrap: true
				});

				return this._contentMessage;
			},
			_createModalTitle: function () {
				return new Text({
					text:  this.i18n.get({
						key: TranslationKeys.SPA_MANAGEMENT_BUTTON_DELETE_MODAL_TITLE,
						params: {1: this.state.manage.spa.name}
					}),
					automationId: AutomationIds.MODAL_TITLE,
					whitespace: true
				});
			},
			_deleteAction: function () {
				this._deleteModal = new Modal({
					automationId: AutomationIds.MODAL,
					owner: this._button,
					icon: SystemIcon.ALERT,
					size: Modal.Size.SMALL,
					label: this._createModalTitle(),
					content: this._createModalContent(),
					buttons: this._createModalActionButtons(),
					buttonsJustification: Modal.ButtonsJustification.CENTER
				});
				this._deleteModal.open();
			},
			_createModalActionButtons: function () {
				this._modalButtonDelete = new Button({
					automationId: AutomationIds.MODAL_DELETE_BUTTON,
					hierarchy: Button.Hierarchy.PRIMARY,
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_BUTTON_DELETE_MODAL_DELETE_BUTTON),
					action: this._modalButtonDeleteAction.bind(this)
				});
				this._modalButtonCancel = new Button({
					automationId: AutomationIds.MODAL_CANCEL_BUTTON,
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_BUTTON_DELETE_MODAL_CANCEL_BUTTON),
					action: this._modalButtonCancelAction.bind(this)
				});

				return [this._modalButtonDelete, this._modalButtonCancel];
			},
			_modalButtonDeleteAction: function () {
				this._disableModalButtons();
				this._spaService.deleteSpa(this.state.manage.spa.id)
					.then(this._deleteSpaResolved.bind(this))
					.catch(this._deleteSpaError.bind(this))
					.finally(this._enableModalButtons.bind(this));
			},
			_modalButtonCancelAction: function () {
				this._closeModal();
			},
			_closeModal: function () {
				this._deleteModal.close();
			},
			_deleteSpaResolved: function () {
				this._closeModal();
				this._routerService.routeTo(RouteList.LIST);
			},
			_deleteSpaError: function (response) {
				this._closeModal();
				if (this._spaService.deleteSpaErrorNotFound(response)) {
					this._routerService.routeTo(RouteList.LIST);
				}
			},
			_disableModalButtons: function () {
				this._modalButtonDelete.enabled = false;
				this._modalButtonCancel.enabled = false;
			},
			_enableModalButtons: function () {
				this._modalButtonDelete.enabled = true;
				this._modalButtonCancel.enabled = true;
			}
		},

		/** @lends DeleteAppButtonPresenter# */
		overrides: {
			_onCreateView: function () {
				this._button = new Button({
					automationId: AutomationIds.MAIN_BUTTON,
					type: Button.Type.GHOST,
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_BUTTON_DELETE),
					size: Button.Size.SMALL,
					action: this._deleteAction.bind(this)
				});

				return this._button;
			}
		},
		static: {
			AutomationIds: Object.freeze({
				MAIN_BUTTON: "manage-spa-basic-info-action-button-delete",
				MODAL: "manage-spa-basic-info-action-button-delete-modal",
				MODAL_CONTENT: "manage-spa-basic-info-action-button-delete-modal-content",
				MODAL_TITLE: "manage-spa-basic-info-action-button-delete-modal-title",
				MODAL_DELETE_BUTTON: "manage-spa-basic-info-action-button-delete-modal-delete-button",
				MODAL_CANCEL_BUTTON: "manage-spa-basic-info-action-button-delete-modal-cancel-button",
			})
		}
	});

	var AutomationIds = DeleteAppButtonPresenter.AutomationIds;

	return DeleteAppButtonPresenter;
});