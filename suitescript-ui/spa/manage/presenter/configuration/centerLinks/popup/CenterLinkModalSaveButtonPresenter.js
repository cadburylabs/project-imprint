define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/CenterLinkModalSaveButtonPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/Button',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/reducer/CenterLinkModalReducer',
	'n/suitescript-ui/spa/manage/reducer/ManageMainReducer',
	'n/suitescript-ui/spa/manage/reducer/Notification',
	'n/suitescript-ui/spa/manage/reducer/SpaReducer'
], function (
	Class,
	Object,
	Presenter,
	Button,
	ServiceList,
	TranslationKeys,
	CenterLinkModalReducer,
	ManageMainReducer,
	Notification,
	SpaReducer
) {
	'use strict';

	var LinkModalSaveButtonPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class LinkModalSaveButtonPresenter
		 * @extends Presenter
		 */
		initialize: function LinkModalSaveButtonPresenter(options) {
			LinkModalSaveButtonPresenter.$super.call(this, options);
			this._spaService = this.context.services.get(ServiceList.SPA);
			this._messageDefinitionService = this.context.services.get(ServiceList.MESSAGE_DEFINITION);
		},

		/** @lends LinkModalSaveButtonPresenter# */
		properties: {},

		/** @lends LinkModalSaveButtonPresenter# */
		methods: {
			_dispatchErrorMessage: function (fieldName) {
				var notification = new Notification({
					type: Notification.TYPE.ERROR,
					definition: this._messageDefinitionService.saveCenterLinkUIValidationError(this._adaptFieldNameForValidationError(fieldName))
				});
				this.dispatchAction(ManageMainReducer.Action.SET_NOTIFICATION, notification);
			},
			_adaptFieldNameForValidationError: function (fieldName) {
				// Remove * sign and convert to propper case
				var newFieldName = fieldName.substring(0, fieldName.length - 1).toLowerCase();
				return newFieldName.charAt(0).toUpperCase() + newFieldName.slice(1)
			},
			_fieldLocationIsValid: function () {
				if (this.state.manage.centerLinkModal.location.category.id === '') {
					var errorObject = this._getErrorObject(false,
						TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_LOCATION_MANDATORY,
						Constants.LOCATION_ERROR)
					this.dispatchAction(
						CenterLinkModalReducer.Action.SET_ERROR,
						errorObject);
					this._dispatchErrorMessage(this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_LOCATION_HEADER));
					return false;
				}
				return true;
			},
			_fieldLinkLabelIsValid: function () {
				if (this.state.manage.centerLinkModal.linkLabel === '') {
					var errorObject = this._getErrorObject(false,
						TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_LINK_LABEL_MANDATORY,
						Constants.LINK_LABEL_ERROR)
					this.dispatchAction(
						CenterLinkModalReducer.Action.SET_ERROR,
						errorObject);
					this._dispatchErrorMessage(this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_LINK_LABEL_HEADER));

					return false;
				}
				return true;
			},
			_fieldsAreValid: function () {
				var fieldLocationIsValid = this._fieldLocationIsValid();
				var fieldLinkLabelIsValid = this._fieldLinkLabelIsValid();

				return fieldLocationIsValid && fieldLinkLabelIsValid;
			},
			_saveSucesful: function (newLink, response) {
				newLink.linkId = response.response;
				this.dispatchAction(SpaReducer.Action.ADD_CENTER_LINK, newLink);
				this._fireEvent(LinkModalSaveButtonPresenter.Event.LINK_SAVED);
			},
			_updateSucesful: function (newLink, response) {
				var oldLinkId = newLink.linkId;
				newLink.linkId = response.response;
				//This needs to be done last otherwise the presenter is disposed when the center link list is updated
				this.context.dispatchAction(SpaReducer.Action.UPDATE_CENTER_LINK, {
					oldLinkId: oldLinkId,
					linkData: newLink
				});

			},
			_saveFailed: function (err) {
				if (err.response !== null && err.response !== undefined) {
					var fieldError = err.response.validationErrors[0].message;
					var errorObject = this._getErrorObject(true, fieldError, Constants.LOCATION_ERROR)
					this.context.dispatchAction(CenterLinkModalReducer.Action.SET_ERROR, errorObject)
				}
			},
			_buttonSaveAction: function () {
				if (this._fieldsAreValid()) {
					this._setSaveButtonEnabled(false);
					var newLink = {
						linkId: this.state.manage.centerLinkModal.linkId,
						label: this.state.manage.centerLinkModal.linkLabel,
						center: this.state.manage.centerLinkModal.location.center,
						section: this.state.manage.centerLinkModal.location.section,
						category: this.state.manage.centerLinkModal.location.category,
						insertBeforeLinkId: this.state.manage.centerLinkModal.insertBefore.id
					};

					var payload = {
						categoryKey: this.state.manage.centerLinkModal.location.category.id,
						insertBeforeLinkKey: this.state.manage.centerLinkModal.insertBefore.id,
						label: this.state.manage.centerLinkModal.linkLabel
					};

					if (this.state.manage.centerLinkModal.linkId === "") {
						this._spaService.saveCenterLink(this.state.manage.spa.id, payload)
							.then(this._saveSucesful.bind(this, newLink))
							.catch(this._saveFailed.bind(this))
					} else {
						this._spaService.updateCenterLink(this.state.manage.spa.id, newLink.linkId, payload)
							.then(this._updateSucesful.bind(this, newLink))
							.catch(this._saveFailed.bind(this))
					}
				}
			},
			_linkLabelErrorChanged: function (old, current) {
				return old.manage.centerLinkModal.linkLabelError !== current.manage.centerLinkModal.linkLabelError;
			},
			_locationErrorChanged: function (old, current) {
				return old.manage.centerLinkModal.locationError !== current.manage.centerLinkModal.locationError;
			},
			_setSaveButtonEnabled: function (enabled) {
				this._saveButton.enabled = enabled;
			},
			_getErrorObject: function (isErrorTranslated, errorMessage, errorField) {
				return {
					isTranslated: isErrorTranslated,
					message: errorMessage,
					field: errorField
				};
			}
		},

		/** @lends LinkModalSaveButtonPresenter# */
		overrides: {
			_onCreateView: function () {
				this._saveButton = new Button({
					automationId: AutomationIds.SAVE_BUTTON,
					hierarchy: Button.Hierarchy.PRIMARY,
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_SAVE_BUTTON),
					action: this._buttonSaveAction.bind(this),
					enabled: false
				});

				return this._saveButton;
			},
			_onStateChanged: function (old, current) {
				if (this._linkLabelErrorChanged(old, current) || this._locationErrorChanged(old, current)
					|| old.manage.centerLinkModal.location.category.id !== current.manage.centerLinkModal.location.category.id
					|| old.manage.centerLinkModal.linkLabel !== current.manage.centerLinkModal.linkLabel
					|| old.manage.centerLinkModal.insertBefore.id !== current.manage.centerLinkModal.insertBefore.id) {
					var linkLabelError = (current.manage.centerLinkModal.linkLabelError.message !== '');
					var locationError = (current.manage.centerLinkModal.locationError.message !== '');
					this._setSaveButtonEnabled(!linkLabelError && !locationError);
					if (!linkLabelError && !locationError &&
						current.manage.centerLinkModal.originalSelection.location.category.id
						=== current.manage.centerLinkModal.location.category.id &&
						current.manage.centerLinkModal.originalSelection.linkLabel
						=== current.manage.centerLinkModal.linkLabel &&
						current.manage.centerLinkModal.originalSelection.insertBefore.id
						=== current.manage.centerLinkModal.insertBefore.id) {
						this._setSaveButtonEnabled(false);
					}
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				SAVE_BUTTON: "manage-spa-configuration-center-link-modal-button-save"
			}),
			Event: Object.freeze({
				LINK_SAVED: 'linkSaved'
			}),
			Constants: Object.freeze({
				LINK_LABEL_ERROR: 'linkLabelError',
				LOCATION_ERROR: 'locationError'

			})
		}
	});

	var AutomationIds = LinkModalSaveButtonPresenter.AutomationIds;
	var Constants = LinkModalSaveButtonPresenter.Constants;

	return LinkModalSaveButtonPresenter;
});