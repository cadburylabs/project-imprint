define('n/suitescript-ui/spa/service/HttpProxyService', [
	'n/ui/classes/Ajax',
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/reducer/RequestsReducer',
	'n/suitescript-ui/spa/manage/reducer/RequestsReducerHelper'
], function (
	Ajax,
	Class,
	Object,
	ServiceList,
	RequestsReducer,
	RequestsReducerHelper
) {
	'use strict';

	var noResponseTypeOptions = {
		async: true,
		dataType: Ajax.DataType.JSON
	};

	var defaultOptions = Object.extend({}, noResponseTypeOptions, {responseType: Ajax.ResponseType.JSON});

	var HttpProxyService = Class.create({
		initialize: function (context) {
			this._context = context.context;
			this._messageDefinitionService = this._context.services.get(ServiceList.MESSAGE_DEFINITION);
		},
		methods: {
			_handleCatch: function (requestKey, id, error) {
				if (requestKey !== undefined) {
					this._context.dispatchAction(
						RequestsReducer.Action.REQUEST_COMPLETED,
						RequestsReducerHelper.createRequestReducerPayload(requestKey, id, error.xhr.status));
				}
				throw error;
			},
			_handleThen: function (requestKey, id, args) {
				if (requestKey !== undefined) {
					this._context.dispatchAction(
						RequestsReducer.Action.REQUEST_COMPLETED,
						RequestsReducerHelper.createRequestReducerPayload(requestKey, id, args.xhr.status));
				}
				return args;
			},
			_start: function (requestKey, id) {
				this._context.dispatchAction(
					RequestsReducer.Action.REQUEST_STARTED,
					RequestsReducerHelper.createRequestReducerPayload(requestKey, id));
			},
			get: function (url, data, options, requestKey, id) {
				this._start(requestKey, id);
				return Ajax.get(url, data, options)
					.then(this._handleThen.bind(this, requestKey, id))
					.catch(this._handleCatch.bind(this, requestKey, id));
			},
			put: function (url, data, options, requestKey, id) {
				return Ajax.put(url, data, options)
					.then(this._handleThen.bind(this, requestKey, id))
					.catch(this._handleCatch.bind(this, requestKey, id));
			},
			delete: function (url, data, options, requestKey, id) {
				return Ajax.delete(url, data, options)
					.then(this._handleThen.bind(this, requestKey, id))
					.catch(this._handleCatch.bind(this, requestKey, id));
			},
			post: function (url, data, options, requestKey, id) {
				return Ajax.post(url, data, options)
					.then(this._handleThen.bind(this, requestKey, id))
					.catch(this._handleCatch.bind(this, requestKey, id));
			},
		},
		static: {
			HTTP_STATUS: Object.freeze({
				NOT_FOUND: 404
			}),
			OPTIONS: Object.freeze({
				NO_RESPONSE_TYPE: noResponseTypeOptions,
				DEFAULT: defaultOptions
			})
		}
	});

	return HttpProxyService;
});
