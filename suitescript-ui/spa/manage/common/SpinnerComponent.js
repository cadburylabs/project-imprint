define('n/suitescript-ui/spa/manage/common/SpinnerComponent', [
	'n/ui/classes/Object',
	'n/ui/widgets/helper/Loader',
	'n/ui/widgets/toolkit/StackPanel'
], function (
	Object,
	Loader,
	StackPanel
) {
	'use strict';

	var defaultOptions = Object.freeze({
		type: Loader.Icon.CIRCULAR,
		style: {}
	})

	var spinnerComponent = {
		new: function (options) {
			var initOptions = Object.extend({}, defaultOptions, options);
			var loader = new Loader({
				class: 'manage-main-presenter-loader',
				rootStyle: initOptions.style,
				icon: initOptions.type,
				verticalAlignment: Loader.VerticalAlignment.MIDDLE,
				horizontalAlignment: Loader.VerticalAlignment.STRETCH
			});

			return new StackPanel({
				orientation: StackPanel.Orientation.VERTICAL,
				items: [loader],
				visible: false
			});
		}
	};

	return spinnerComponent;
});
