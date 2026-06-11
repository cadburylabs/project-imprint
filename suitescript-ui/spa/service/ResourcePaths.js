define('n/suitescript-ui/spa/service/ResourcePaths', [
	'n/ui/classes/Object',
	'n/suitescript-ui/spa/service/RestResource',
	'n/suitescript-ui/spa/service/UrlQueryParam'
], function (
	Object,
	RestResource,
	UrlQueryParam
) {
	'use strict';

	var ResourcePaths = Object.freeze({
		/**
		 * @return {string}
		 */
		BASE_PATH: '/spa-api',
		SPA: Object.freeze({
			/**
			 * @return {string}
			 */
			RESOURCE: function (spaId) {
				var base = ResourcePaths.BASE_PATH + '/' + RestResource.SPA;
				if (!spaId) {
					return base;
				}
				return base + '/' + spaId;
			},
			SUBRESOURCE: Object.freeze({
				/**
				 * @return {string}
				 */
				LOG: function (spaId, pageSize, pageNumber) {
					var base = ResourcePaths.SPA.RESOURCE(spaId) + '/' + RestResource.LOG;
					return base
						+ '?' + UrlQueryParam.PAGE_SIZE + '=' + pageSize
						+ '&' + UrlQueryParam.PAGE_NUMBER + '=' + pageNumber;
				},
				/**
				 * @return {string}
				 */
				LINK: function (spaId, linkId) {
					var base = ResourcePaths.SPA.RESOURCE(spaId) + '/' + RestResource.LINK;
					if (!linkId) {
						return base;
					}
					return base + '/' + linkId;
				},
				/**
				 * @return {string}
				 */
				ERROR_NOTIFICATION: function (spaId) {
					return ResourcePaths.SPA.RESOURCE(spaId) + '/' + RestResource.ERROR_NOTIFICATION;
				},
				/**
				 * @return {string}
				 */
				AUDIENCE: function (spaId) {
					return ResourcePaths.SPA.RESOURCE(spaId) + '/' + RestResource.AUDIENCE;
				}
			})
		}),
		EXECUTION_ROLE: Object.freeze({
			/**
			 * @return {string}
			 */
			RESOURCE: function (deploymentKey) {
				var base = ResourcePaths.BASE_PATH + '/' + RestResource.EXECUTIONROLE;
				return base
					+ '?' + UrlQueryParam.DEPLOYMENT_KEY + '=' + deploymentKey;
			}
		}),
		AUDIENCE_ROLE: Object.freeze({
			/**
			 * @return {string}
			 */
			RESOURCE: function (deploymentKey) {
				var base = ResourcePaths.BASE_PATH + '/' + RestResource.AUDIENCEROLE;
				return base
					+ '?' + UrlQueryParam.DEPLOYMENT_KEY + '=' + deploymentKey;
			}
		}),
		USER: Object.freeze({
			/**
			 * @return {string}
			 */
			RESOURCE: function (serverScriptKey) {
				var base = ResourcePaths.BASE_PATH + '/' + RestResource.USER;
				return base
					+ '?' + UrlQueryParam.SERVER_SCRIPT_KEY + '=' + serverScriptKey;
			}
		}),
		LOGLEVEL: Object.freeze({
			/**
			 * @return {string}
			 */
			RESOURCE: function (deploymentKey) {
				var base = ResourcePaths.BASE_PATH + '/' + RestResource.LOGLEVEL;
				return base
					+ '?' + UrlQueryParam.DEPLOYMENT_KEY + '=' + deploymentKey;
			}
		}),
		SUITEAPP: Object.freeze({
			/**
			 * @return {string}
			 */
			RESOURCE: function () {
				return ResourcePaths.BASE_PATH + '/' + RestResource.SUITEAPP;
			}
		}),
		USER_GROUP: Object.freeze({
			/**
			 * @return {string}
			 */
			RESOURCE:function (scriptId) {
				var base = ResourcePaths.BASE_PATH + '/' + RestResource.USER_GROUP;
				return base
					+ '?' + UrlQueryParam.SCRIPT_ID + '=' + scriptId;
			}
		}) ,
		CENTER: Object.freeze({
			/**
			 * @return {string}
			 */
			RESOURCE: function () {
				return ResourcePaths.BASE_PATH + '/' + RestResource.CENTER;
			}
		}) ,
		CATEGORY: Object.freeze({
			/**
			 * @return {string}
			 */
			RESOURCE: function(categoryId){
				return ResourcePaths.BASE_PATH + '/' + RestResource.CATEGORY + '/' + categoryId
			},
			SUBRESOURCE: Object.freeze({
				/**
				 * @return {string}
				 */
				LINK:function (categoryId) {
					return ResourcePaths.CATEGORY.RESOURCE(categoryId)  + '/' + RestResource.LINK;
				}
			})
		})
	});

	return ResourcePaths;
});
