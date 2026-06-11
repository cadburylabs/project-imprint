define('n/suitescript-ui/spa/manage/presenter/configuration/releaseAudience/SetupAudienceButtonPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/Button',
	'n/ui/widgets/toolkit/Modal',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/layout/GapSize',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/presenter/configuration/releaseAudience/AudienceModalRolesPresenter',
	'n/suitescript-ui/spa/manage/reducer/SpaAudienceReducer',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function (
	Class,
	Object,
	Presenter,
	Button,
	Modal,
	StackPanel,
	GapSize,
	ServiceList,
	TranslationKeys,
	AudienceModalRolesPresenter,
	SpaAudienceReducer,
	StateProps
) {
	'use strict';

	var SetupAudienceButtonPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class SetupAudienceButtonPresenter
		 * @extends Presenter
		 */
		initialize: function SetupAudienceButtonPresenter(options) {
			this.constructor.$super.call(this, options);
			this._spaService = this.context.services.get(ServiceList.SPA);
		},

		/** @lends SetupAudienceButtonPresenter# */
		properties: {},

		/** @lends SetupAudienceButtonPresenter# */
		methods: {
			_createAudienceModalButton: function () {
				return new Button({
					label: this.i18n.get(Constants.FIELD_DETAILS.BUTTON_LABEL),
					type: Button.Type.GHOST,
					action: this._setUpAudienceButtonClicked.bind(this),
					automationId: AutomationIds.MODAL_OPEN_AUDIENCE_BUTTON,
					classList: CssClass.EDITABLE_FIELD
				});
			},
			_setUpAudienceButtonClicked: function () {
				this.dispatchAction(SpaAudienceReducer.Action.SETUP_AUDIENCE_BUTTON_CLICKED);
			},
			_createAudienceModal: function (owner) {
				return new Modal({
					automationId: AutomationIds.MODAL,
					owner: owner,
					size: Modal.Size.DEFAULT,
					title: this.i18n.get(Constants.FIELD_DETAILS.MODAL_TITLE),
					content: this._createModalContent(),
					buttons: this._createModalActionButtons(),
					on: {
						closed: this._closeButtonClicked.bind(this)
					}
				});
			},
			_closeButtonClicked: function () {
				if (this.state.manage.spa.audience.state !== StateProps.SPA.AUDIENCE.STATE.IDLE) {
					this.dispatchAction(SpaAudienceReducer.Action.CANCEL_EDIT_BUTTON_CLICKED);
				}
			},
			_createModalContent: function () {
				var content = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL,
					itemGap: GapSize.MEDIUM,
					outerGap: GapSize.MEDIUM,
					alignment: StackPanel.Alignment.START
				});
				content.add(this._createChild(AudienceModalRolesPresenter).createView());
				return content;
			},
			_createModalActionButtons: function () {
				return [this._createSaveButton(), this._createCancelButton()]
			},
			_createSaveButton: function () {
				this._saveButton = new Button({
					automationId: AutomationIds.MODAL_SAVE_BUTTON,
					hierarchy: Button.Hierarchy.PRIMARY,
					label: this.i18n.get(Constants.FIELD_DETAILS.MODAL_SAVE_BUTTON_LABEL),
					action: this._modalButtonSaveAction.bind(this)
				});
				return this._saveButton;
			},
			_createCancelButton: function () {
				this._cancelButton = new Button({
					automationId: AutomationIds.MODAL_CANCEL_BUTTON,
					label: this.i18n.get(Constants.FIELD_DETAILS.MODAL_CANCEL_BUTTON_LABEL),
					action: this._modalButtonCancelAction.bind(this)
				});
				return this._cancelButton;
			},
			_modalButtonSaveAction: function () {
				this.dispatchAction(SpaAudienceReducer.Action.SAVE_EDIT_BUTTON_CLICKED);
			},
			_modalButtonCancelAction: function () {
				this.dispatchAction(SpaAudienceReducer.Action.CANCEL_EDIT_BUTTON_CLICKED);
			},
			_startEditing: function () {
				this._cancelButton.enabled = true;
				this._setSaveButtonEnabled(!Object.equals(this.state.manage.spa.audience.original, this.state.manage.spa.audience.editing));
				this._audienceModal.open();
			},
			_stopEditing: function () {
				this._audienceModal.close();
			},
			_saveFinishedSuccesfully: function () {
				this.dispatchAction(SpaAudienceReducer.Action.SAVE_FINISHED_SUCCESFULLY);
			},
			_saveFailed: function () {
				this.dispatchAction(SpaAudienceReducer.Action.SAVE_UPDATE_FAILED);
			},
			_saveEdit: function () {
				this._saveButton.enabled = false;
				this._cancelButton.enabled = false;
				var newAudience = this.context.state.manage.spa.audience.editing.roles;

				this._spaService.updateAudience(this.context.state.manage.spa.id, newAudience)
					.then(this._saveFinishedSuccesfully.bind(this))
					.catch(this._saveFailed.bind(this));
			},
			_stateChanged: function (currentState) {
				if (this._stateChangedFunction[currentState] === undefined) throw "state not supported";
				this._stateChangedFunction[currentState]();
			},
			_setupStateChangedFunctions: function () {
				this._stateChangedFunction = [];
				this._stateChangedFunction[StateProps.SPA.AUDIENCE.STATE.EDITING] = this._startEditing.bind(this);
				this._stateChangedFunction[StateProps.SPA.AUDIENCE.STATE.IDLE] = this._stopEditing.bind(this);
				this._stateChangedFunction[StateProps.SPA.AUDIENCE.STATE.SAVING] = this._saveEdit.bind(this);
			},
			_setSaveButtonEnabled: function (enabled) {
				this._saveButton.enabled = enabled;
			}
		},

		/** @lends SetupAudienceButtonPresenter# */
		overrides: {
			_onCreateView: function () {
				this._setupStateChangedFunctions();
				this._openModalButton = this._createAudienceModalButton();
				this._audienceModal = this._createAudienceModal(this._openModalButton);
				this._setSaveButtonEnabled(!Object.equals(this.state.manage.spa.audience.original, this.state.manage.spa.audience.editing));
				return this._openModalButton;
			},
			_onStateChanged: function(oldState, currentState) {
				if(oldState.manage.spa.audience.state !== currentState.manage.spa.audience.state) {
					this._stateChanged(currentState.manage.spa.audience.state);
				}
				if (!Object.equals(oldState.manage.spa.audience.editing,currentState.manage.spa.audience.editing)
						|| !Object.equals(oldState.manage.spa.audience.original, currentState.manage.spa.audience.original)) {
					this._setSaveButtonEnabled(!Object.equals(currentState.manage.spa.audience.original, currentState.manage.spa.audience.editing));
				}
			}
		},
		static: {
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					BUTTON_LABEL: TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_RELEASE_AUDIENCE_SETUP_AUDIENCE_BUTTON_LABEL,
					MODAL_TITLE: TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_RELEASE_AUDIENCE_SETUP_AUDIENCE_MODAL_TITLE,
					MODAL_SAVE_BUTTON_LABEL: TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_RELEASE_AUDIENCE_SETUP_AUDIENCE_MODAL_SAVE_BUTTON,
					MODAL_CANCEL_BUTTON_LABEL: TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_RELEASE_AUDIENCE_SETUP_AUDIENCE_MODAL_CANCEL_BUTTON,
				})
			}),
			CssClass: Object.freeze({
				EDITABLE_FIELD: 'n-ssui-spa-manage-editable-field'
			}),
			AutomationIds: Object.freeze({
				MODAL_OPEN_AUDIENCE_BUTTON: "manage-spa-configuration-open-setup-audience-button",
				MODAL: "manage-spa-configuration-setup-audience-modal",
				MODAL_TITLE: "manage-spa-configuration-setup-audience-modal-title",
				MODAL_SAVE_BUTTON: "manage-spa-configuration-setup-audience-modal-save-button",
				MODAL_CANCEL_BUTTON: "manage-spa-configuration-setup-audience-modal-cancel-button",
			})
		}
	});

	var Constants = SetupAudienceButtonPresenter.Constants;
	var CssClass = SetupAudienceButtonPresenter.CssClass;
	var AutomationIds = SetupAudienceButtonPresenter.AutomationIds;

	return SetupAudienceButtonPresenter;
});