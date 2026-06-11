define('n/suitescript-ui/spa/service/SpaService', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/reducer/ManageMainReducer',
	'n/suitescript-ui/spa/manage/reducer/Notification',
	'n/suitescript-ui/spa/manage/reducer/RequestsReducerHelper',
	'n/suitescript-ui/spa/service/HttpProxyService',
	'n/suitescript-ui/spa/service/ResourcePaths'
], function (
	Class,
	Object,
	ServiceList,
	ManageMainReducer,
	Notification,
	RequestsReducerHelper,
	HttpProxyService,
	ResourcePaths
) {
	'use strict';

	function mapSpaToUpdateSpaBody(spa) {
		return Object.freeze({
			id: spa.id,
			name: spa.name,
			description: spa.description,
			url : spa.url,
			ownerId : spa.ownerId,
			executeAsRoleId : spa.executeAsRoleId,
			logLevelId : spa.logLevelId,
			usesUif : spa.usesUif
		});
	}

	var noResponseTypeOptions = HttpProxyService.OPTIONS.NO_RESPONSE_TYPE;

	var defaultOptions = HttpProxyService.OPTIONS.DEFAULT;

	var SpaService = Class.create({
		initialize: function SpaService(context) {
			this._context = context.context;
			this._messageDefinitionService = this._context.services.get(ServiceList.MESSAGE_DEFINITION);
			this._httpProxyService = this._context.services.get(ServiceList.HTTP_PROXY_SERVICE);
		},
		methods: {
			_dispatchMessage: function (type, messageDefinition) {
				var notification = new Notification({
					type: type,
					definition: messageDefinition
				});
				this._context.dispatchAction(ManageMainReducer.Action.SET_NOTIFICATION, notification);
			},
			_dispatchSuccessMessage: function (messageDefinition, response) {
				this._dispatchMessage(Notification.TYPE.SUCCESS, messageDefinition);
				return response;
			},
			_dispatchErrorMessage: function (messageDefinition, err) {
				this._dispatchMessage(Notification.TYPE.ERROR, messageDefinition);
				throw err;
			},
			getSpaList: function () {
				return this._httpProxyService.get(ResourcePaths.SPA.RESOURCE(), null, defaultOptions);
			},
			getSpaLogs: function (id, pageSize, pageNumber) {
				return this._httpProxyService.get(ResourcePaths.SPA.SUBRESOURCE.LOG(id, pageSize, pageNumber), null, defaultOptions);
			},
			getSpaDetails: function (id) {
				return this._httpProxyService.get(
					ResourcePaths.SPA.RESOURCE(id),
					null,
					defaultOptions,
					RequestsReducerHelper.REDUCER_KEYS.SPA_DETAILS,
					id);
			},
			_updateSpaError: function (fieldTitle, err) {
				var messageDefinition = this._messageDefinitionService.updateSpaError(fieldTitle);
				if (err.response != null && err.response.message === SpaService.UPDATE_SPA.VALIDATION_EXCEPTION) {
					messageDefinition = this._messageDefinitionService.updateSpaValidationError(fieldTitle);
				}
				this._dispatchErrorMessage(messageDefinition, err);
			},
			updateSpa: function (id, data, fieldTitle) {
				return this._httpProxyService.put(
					ResourcePaths.SPA.RESOURCE(id),
					mapSpaToUpdateSpaBody(data),
					defaultOptions)
					.then(this._dispatchSuccessMessage.bind(this, this._messageDefinitionService.updateSpaSuccess(fieldTitle)))
					.catch(this._updateSpaError.bind(this, fieldTitle));
			},
			updateSpaGetSingleError: function (fieldTitle, ajaxResponse) {
				if (ajaxResponse.response && ajaxResponse.response.validationErrors) {
					return this._messageDefinitionService.updateSpaValidationErrorContent(fieldTitle);
				}
				return this._messageDefinitionService.updateSpaErrorContent(fieldTitle);
			},
			_deleteSpaError: function (err) {
				var messageDefinition = this._messageDefinitionService.deleteSpaInternalError();
				if (this.deleteSpaErrorNotFound(err)) {
					messageDefinition = this._messageDefinitionService.deleteSpaErrorNotFound();
				}
				this._dispatchErrorMessage(messageDefinition, err);
			},
			deleteSpa: function (id) {
				return this._httpProxyService.delete(ResourcePaths.SPA.RESOURCE(id), null, defaultOptions)
					.then(this._dispatchSuccessMessage.bind(this, this._messageDefinitionService.spaDeleteSuccesful()))
					.catch(this._deleteSpaError.bind(this));
			},
			deleteSpaErrorNotFound: function (response) {
				return (response.xhr.status === 404);
			},
			_saveCenterLinkError: function (err) {
				var messageDefinition = this._messageDefinitionService.saveCenterLinkInternalError();
				if (err.response !== null && err.response !== undefined) {
					var fieldError = err.response.validationErrors[0].message;
					messageDefinition = this._messageDefinitionService.saveCenterLinkValidationError(fieldError)
				}
				this._dispatchErrorMessage(messageDefinition, err);
			},
			saveCenterLink: function (id, payload) {
				return this._httpProxyService.post(ResourcePaths.SPA.SUBRESOURCE.LINK(id), payload, defaultOptions)
					.then(this._dispatchSuccessMessage.bind(this, this._messageDefinitionService.saveCenterLinkSuccess()))
					.catch(this._saveCenterLinkError.bind(this));
			},
			updateCenterLink: function (id, linkId, payload) {
				return this._httpProxyService.put(ResourcePaths.SPA.SUBRESOURCE.LINK(id, linkId), payload, defaultOptions)
					.then(this._dispatchSuccessMessage.bind(this, this._messageDefinitionService.updateCenterLinkSuccess()))
					.catch(this._saveCenterLinkError.bind(this));
			},
			getCenterLinkList: function (id) {
				return this._httpProxyService.get(ResourcePaths.SPA.SUBRESOURCE.LINK(id), null, defaultOptions)
					.catch(this._dispatchErrorMessage.bind(this, this._messageDefinitionService.getCenterLinkListFailed()));
			},
			deleteLink: function (id, linkId) {
				return this._httpProxyService.delete(ResourcePaths.SPA.SUBRESOURCE.LINK(id, linkId), null, defaultOptions)
					.then(this._dispatchSuccessMessage.bind(this, this._messageDefinitionService.deleteLinkSuccess()))
					.catch(this._dispatchErrorMessage.bind(this, this._messageDefinitionService.deleteLinkError()))
			},
			getErrorNotifications: function (spaId) {
				return this._httpProxyService.get(ResourcePaths.SPA.SUBRESOURCE.ERROR_NOTIFICATION(spaId), null, defaultOptions);
			},
			updateErrorNotifications: function (id, payload) {
				return this._httpProxyService.put(ResourcePaths.SPA.SUBRESOURCE.ERROR_NOTIFICATION(id), payload, noResponseTypeOptions)
					.then(this._dispatchSuccessMessage.bind(this, this._messageDefinitionService.updateErrorNotificationsSuccess()))
					.catch(this._dispatchErrorMessage.bind(this, this._messageDefinitionService.updateErrorNotificationsError()));
			},
			getAudience: function (id) {
				return this._httpProxyService.get(ResourcePaths.SPA.SUBRESOURCE.AUDIENCE(id), null, defaultOptions)
			},
			updateAudience: function (id, payload) {
				return this._httpProxyService.put(ResourcePaths.SPA.SUBRESOURCE.AUDIENCE(id), payload, noResponseTypeOptions)
					.then(this._dispatchSuccessMessage.bind(this, this._messageDefinitionService.updateAudienceSuccess()))
					.catch(this._dispatchErrorMessage.bind(this, this._messageDefinitionService.updateAudienceError()));
			}
		},
		static: {
			UPDATE_SPA: Object.freeze({
				VALIDATION_EXCEPTION: "ValidationException"
			})
		}
	});

	return SpaService;
});
