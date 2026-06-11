define('n/platform/systemnotes2/service/SnService', [
	'n/ui/classes/Ajax'
], function (
	Ajax
) {
	'use strict';

	var DATA_SOURCE_URL = '/systemnotes2/SystemNotesRequest.nl';
	var TIMEOUT = 180 * 1000;

	var getRequests = function (eid, pdid, key, offset, dateStart, dateEnd) {
		var dStart = dateStart === null ? '' : ((dateStart.month + 1) + '/' + dateStart.day + '/' + dateStart.year);
		var dEnd = dateEnd === null ? '' : ((dateEnd.month + 1) + '/' + dateEnd.day + '/' + dateEnd.year);
		var parameters = {action: "list", eid: eid, pdid: pdid, offset: offset, dstart: dStart, dend: dEnd};
		var parametersKey = Object.assign(parameters, key);
		var res = Ajax.get(DATA_SOURCE_URL, parametersKey, {timeout: TIMEOUT});
		return res;
	};

	return {
		getRequests: getRequests
	};
});