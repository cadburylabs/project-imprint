define('n/suitescript-ui/spa/manage/reducer/Notification', [
		'n/ui/classes/Class',
		'n/ui/classes/Object',
		'n/ui/classes/immutable/ImmutableObject'
	],
	function (
		Class,
		Object,
		ImmutableObject
	) {
		'use strict';
		var Notification = Class.create({
			initialize: function (options) {
				options = ImmutableObject.merge(defaultOptions, options || {});
				this._type = options.type;
				this._definition = options.definition;
			},

			properties: {
				type: {},
				definition: {}
			},
			methods: {
				isSuccessType: function () {
					return (this._type === Notification.TYPE.SUCCESS);
				}
			},
			static: {
				TYPE: Object.freeze({
					SUCCESS: 'success',
					ERROR: 'error'
				})
			}
		});

		var defaultOptions = Object.freeze({
		});

		return Notification
});
