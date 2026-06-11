define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/CenterLinkDeleteButtonPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Button',
	'n/ui/widgets/toolkit/Modal',
	'n/ui/widgets/toolkit/Text',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/reducer/CenterLinkDeleteModalReducer',
	'n/suitescript-ui/spa/manage/reducer/SpaReducer'
], function (
	Class,
	Object,
	Presenter,
	SystemIcon,
	Button,
	Modal,
	Text,
	ServiceList,
	TranslationKeys,
	CenterLinkDeleteModalReducer,
	SpaReducer
) {
	'use strict';

	var CenterLinkDeleteButtonPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class CenterLinkDeleteButtonPresenter
		 * @extends Presenter
		 */
		initialize: function CenterLinkDeleteButtonPresenter(options) {
			CenterLinkDeleteButtonPresenter.$super.call(this, options);

			this.linkId = options.linkId;
			this._spaService = this.context.services.get(ServiceList.SPA);
		},

		/** @lends CenterLinkDeleteButtonPresenter# */
		properties: {
			linkId: {
				writable: true
			}
		},

		/** @lends CenterLinkDeleteButtonPresenter# */
		methods: {
			_createModalContent: function () {
				this._contentMessage = new Text({
					automationId: AutomationIds.MODAL_CONTENT,
					text: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_DELETE_BUTTON_MODAL_CONTENT),
					wrap: true
				});

				return this._contentMessage;
			},
			_createModalTitle: function () {
				this._modalTitle = new Text({
					text: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_DELETE_BUTTON_MODAL_TITLE),
					automationId: AutomationIds.MODAL_TITLE,
					whitespace: true
				});

				return this._modalTitle;
			},
			_deleteAction: function () {
				this.dispatchAction(CenterLinkDeleteModalReducer.Action.DELETE_BUTTON_CLICKED, this.linkId);
				this._deleteModal.open();
			},
			_createModalActionButtons: function () {
				this._modalButtonDelete = new Button({
					automationId: AutomationIds.MODAL_DELETE_BUTTON,
					hierarchy: Button.Hierarchy.PRIMARY,
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_DELETE_BUTTON_MODAL_DELETE_BUTTON),
					action: this._modalButtonDeleteAction.bind(this)
				});
				this._modalButtonCancel = new Button({
					automationId: AutomationIds.MODAL_CANCEL_BUTTON,
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_DELETE_BUTTON_MODAL_CANCEL_BUTTON),
					action: this._modalButtonCancelAction.bind(this)
				});

				return [this._modalButtonDelete, this._modalButtonCancel];
			},
			_modalButtonDeleteAction: function () {
				this.context.dispatchAction(CenterLinkDeleteModalReducer.Action.DELETE_CONFIRMATION_BUTTON_CLICKED);
				this._spaService.deleteLink(this.state.manage.spa.id, this.state.manage.centerLinkDeleteModal.linkId)
					.then(this._deleteLinkResolved.bind(this))
					.catch(this._deleteLinkError.bind(this));
			},
			_modalButtonCancelAction: function () {
				this._closeModal()
			},
			_closeModal: function () {
				this._deleteModal.close();
			},
			_deleteLinkResolved: function () {
				this.dispatchAction(CenterLinkDeleteModalReducer.Action.LINK_DELETED_SUCCESS);
				this.dispatchAction(SpaReducer.Action.DELETE_CENTER_LINK, this.state.manage.centerLinkDeleteModal.linkId);
			},
			_deleteLinkError: function (response) {
				this.dispatchAction(CenterLinkDeleteModalReducer.Action.LINK_DELETE_FAILED);
			},
			_setButtonsEnabled: function (enabled) {
				if (this._modalButtonDelete && this._modalButtonCancel) {
					this._modalButtonDelete.enabled = enabled;
					this._modalButtonCancel.enabled = enabled;
				}
			},
			_saveFinished: function () {
				this._closeModal();
			},
			_isCurrentDeleteLink: function (currentState) {
				return this.linkId === currentState.manage.centerLinkDeleteModal.linkId
			},
			_savingStateChanged: function (oldState, currentState) {
				return oldState.manage.centerLinkDeleteModal.isSaving !== currentState.manage.centerLinkDeleteModal.isSaving
			},
			_savingProcessFinished: function (oldState, currentState) {
				return oldState.manage.centerLinkDeleteModal.isSaving && !currentState.manage.centerLinkDeleteModal.isSaving
			}
		},

		/** @lends CenterLinkDeleteButtonPresenter# */
		overrides: {
			_onCreateView: function () {
				this._button = new Button({
					icon: SystemIcon.DELETE.withCaption('Delete'),
					type: Button.Type.PURE,
					action: this._deleteAction.bind(this),
					automationId: AutomationIds.DELETE_BUTTON_PREFIX + this.linkId
				});

				this._deleteModal = new Modal({
					automationId: AutomationIds.MODAL,
					owner: this._button,
					icon: SystemIcon.ALERT,
					size: Modal.Size.SMALL,
					label: this._createModalTitle(),
					content: this._createModalContent(),
					buttons: this._createModalActionButtons(),
					buttonsJustification: Modal.ButtonsJustification.CENTER,
				});

				return this._button;
			},
			_onStateChanged: function (old, current) {
				if (this._isCurrentDeleteLink(current) && old.manage.centerLinkDeleteModal !== current.manage.centerLinkDeleteModal) {

					if (this._savingStateChanged(old, current)) {
						this._setButtonsEnabled(!current.manage.centerLinkDeleteModal.isSaving);
					}
					if (this._savingProcessFinished(old, current)) {
						this._saveFinished()
					}
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				MODAL: "manage-spa-configuration-center-link-list-delete-modal",
				MODAL_CONTENT: "manage-spa-configuration-center-link-list-delete-content",
				MODAL_TITLE: "manage-spa-configuration-center-link-list-delete-title",
				MODAL_DELETE_BUTTON: "manage-spa-configuration-center-link-list-delete-delete-button",
				MODAL_CANCEL_BUTTON: "manage-spa-configuration-center-link-list-delete-cancel-button",
				DELETE_BUTTON_PREFIX: "manage-spa-configuration-center-link-list-delete-"
			})
		}
	});

	var AutomationIds = CenterLinkDeleteButtonPresenter.AutomationIds;

	return CenterLinkDeleteButtonPresenter;
});