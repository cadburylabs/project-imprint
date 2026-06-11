define('n/suitescript-ui/spa/manage/reducer/RequestsReducerHelper', [
	'n/ui/classes/Object'
], function (
	Object
) {
	'use strict';

	var RequestsReducerHelper = Object.create({
		createRequestReducerPayload: function (key, id, status) {
			return {
				key: key,
				id: id,
				status: status
			}
		},
		REDUCER_KEYS: Object.freeze({
			SPA_DETAILS: 'spaDetails'
		})
	});

	return RequestsReducerHelper;
});
