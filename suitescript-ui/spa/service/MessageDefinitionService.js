define('n/suitescript-ui/spa/service/MessageDefinitionService', [
		'n/ui/classes/Class',
		'n/ui/compounds/notification/UserMessageService',
		'n/ui/widgets/Service',
		'n/ui/widgets/toolkit/Text',
		'n/suitescript-ui/spa/manage/TranslationKeys'
	],
	function(
		Class,
		UserMessageService,
		Service,
		Text,
		TranslationKeys
	) {
		'use strict';
		var automationIds = {
			spaDoesNotExist: 'spa-list-banner-spa-does-not-exist'
		}

		var MessageDefinitionService = Class.create({
			initialize: function (context) {
				this._context = context.context;
				this._i18n = this._context.services.get(Service.I18N);
			},
			methods: {
				growl: function (title, content) {
					return {
						displayType: UserMessageService.DisplayType.GROWL,
						showCloseButton: true,
						title: title,
						content: content,
						duration: 5000,
						closeOnClick: true
					};
				},
				banner: function (component) {
					return {
						displayType: UserMessageService.DisplayType.BANNER,
						showCloseButton: true,
						content: component,
						closeOnClick: true
					};
				},
				spaDoesNotExist: function () {
					return this.banner(new Text({
						text: this._i18n.get(TranslationKeys.SPA_RENDER_SPA_DOES_NOT_EXIST),
						automationId: automationIds.spaDoesNotExist
					}));
				},
				updateSpaSuccess: function (fieldTitle) {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_FIELD_UPDATED_TITLE),
						this._i18n.get({
							key: TranslationKeys.SPA_MANAGEMENT_FIELD_UPDATED_CONTENT,
							params: {1: fieldTitle}
						})
					);
				},
				updateSpaErrorContent: function (fieldTitle) {
					return this._i18n.get({
						key: TranslationKeys.SPA_MANAGEMENT_FIELD_UPDATE_ERROR_CONTENT,
						params: {1: fieldTitle}
					});
				},
				updateSpaError: function (fieldTitle) {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_FIELD_UPDATE_ERROR_TITLE),
						this.updateSpaErrorContent(fieldTitle)
					);
				},
				updateSpaValidationErrorContent: function (fieldTitle) {
					return this._i18n.get({
						key: TranslationKeys.SPA_MANAGEMENT_FIELD_UPDATE_VALIDATION_ERROR_CONTENT,
						params: {1: fieldTitle}
					});
				},
				updateSpaValidationError: function (fieldTitle) {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_FIELD_UPDATE_VALIDATION_ERROR_TITLE),
						this.updateSpaValidationErrorContent(fieldTitle)
					);
				},
				spaDeleteSuccesful: function () {
					return this.banner(
						this._i18n.get({
							key: TranslationKeys.SPA_MANAGEMENT_SPA_DELETE_SUCCESS,
							params: {1: this._context.state.manage.spa.name}
					}));
				},
				_spaDeleteError: function (content) {
					return this.banner(content);
				},
				deleteSpaErrorNotFound: function () {
					return this._spaDeleteError(this._i18n.get(TranslationKeys.SPA_MANAGEMENT_SPA_DELETE_ERROR_NOT_FOUND));
				},
				deleteSpaInternalError: function () {
					return this._spaDeleteError(this._i18n.get(TranslationKeys.SPA_MANAGEMENT_SPA_DELETE_ERROR_INTERNAL_ERROR));
				},
				saveCenterLinkSuccess: function () {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_SUCCESSFUL_CREATION_TITLE),
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_SUCCESSFUL_CREATION_CONTENT)
					);
				},
				updateCenterLinkSuccess: function () {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_SUCCESSFUL_UPDATE_TITLE),
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_SUCCESSFUL_UPDATE_CONTENT)
					);
				},
				saveCenterLinkValidationError: function (fieldError) {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_SAVE_ERROR_TITLE),
						fieldError
					);
				},
				saveCenterLinkUIValidationError: function (fieldName) {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_VALIDATION_FAIL_TITLE),
						this._i18n.get({
							key: TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_VALIDATION_FAIL,
							params: {1: fieldName}
						})
					);
				},
				saveCenterLinkInternalError: function () {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_SAVE_ERROR_TITLE),
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_SAVE_ERROR_CONTENT)
					);
				},
				deleteLinkSuccess: function () {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_DELETE_SUCCESS_TITLE),
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_DELETE_SUCCESS_CONTENT)
					);
				},
				deleteLinkError: function () {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_DELETE_ERROR_INTERNAL_SERVER_ERROR_TITLE),
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_DELETE_ERROR_INTERNAL_SERVER_ERROR_CONTENT)
					);
				},
				updateErrorNotificationsSuccess: function () {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_SUCCESSFUL_SAVE_TITLE),
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_SUCCESSFUL_SAVE_CONTENT)
					);
				},
				updateErrorNotificationsError: function () {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_SAVE_ERROR_TITLE),
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_SAVE_ERROR_CONTENT)
					);
				},
				updateAudienceSuccess: function () {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_AUDIENCE_SUCCESSFUL_UPDATE_TITLE),
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_AUDIENCE_SUCCESSFUL_UPDATE_CONTENT)
					);
				},
				updateAudienceError: function () {
					return this.growl(
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_AUDIENCE_SAVE_ERROR_TITLE),
						this._i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_AUDIENCE_SAVE_ERROR_CONTENT)
					);
				},
				getCenterLinkListFailed: function () {
					return this.growl(
						"Something went wrong :'(",
						"Center Links for tis SPA could not be obtained at this time"
					);
				},
				spaCreatedBanner: function (content) {
					return this.banner(content);
				}
			}
		});

		return MessageDefinitionService;
});
