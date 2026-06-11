define('n/ui/form/SubrecordWrapper', [
	'n/ui/classes/Class',
	'n/ui/form/RecordWrapper'
], function (
	Class,
	RecordWrapper
) {
	'use strict';

	var SubrecordWrapper = Class.create({
		extend: RecordWrapper,

		/**
		 * @class SubrecordWrapper
		 * @extends RecordWrapper
		 * @param {Object} options
		 */
		initialize: function SubrecordWrapper(options) {
			SubrecordWrapper.$super.call(this, options);
		},

		/** @lends RecordWrapper# */
		methods: {
			commit: function () {
				return this._record.commit();
			},

			cancel: function () {
				return this._record.cancel();
			},
		},

		/** @lends SubrecordWrapper# */
		overrides: {
			save: function () {
				return this.commit();
			}
		}
	});

	return SubrecordWrapper;
});
