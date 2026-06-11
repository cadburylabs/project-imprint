define('n/ui/form/AssistiveContent', [
	'n/ui/classes/Array',
	'n/ui/classes/Class',
	'n/ui/classes/Log',
	'n/ui/classes/Object',
	'n/ui/classes/Type',
	'n/ui/widgets/HtmlWrapper',
	'n/ui/widgets/ImageMetadata',
	'n/ui/widgets/helper/Dom',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Image'
], function (
	Array,
	Class,
	Log,
	Object,
	Type,
	HtmlWrapper,
	ImageMetadata,
	Dom,
	SystemIcon,
	Image
) {
	'use strict';

	var AssistiveContent = Class.create({
		/**
		 * @class AssistiveContent
		 * @param {Object} options
		 */
		initialize: function AssistiveContent(options) {
			this._viewModel = options.viewModel;
			this._view = null;

			if (Type.Function.is(this._viewModel.onPropertyChanged)) {
				this._viewModel.onPropertyChanged( (e) => {
					if (e.propertyName === 'assistiveContentData') {
						if (Type.Value.is(this._view)) {
							var content = this._createContent();
							this._view.content = function () {
								return content;
							};
						}
					}
				});
			}
		},

		/** @lends AssistiveContent# */
		methods: {
			getView: function () {
				var content = this._createContent();
				this._view = new HtmlWrapper({
					content: function () {
						return content;
					}
				});

				return this._view;
			},

			_createContent: function () {
				var items = [];
				var data = Type.Value.is(this._viewModel.assistiveContentData) ? this._viewModel.assistiveContentData : {};
				var hasIcon = false;

				if (Type.Value.is(data.text)) {
					if (Type.Value.is(data.icon)) {
						var icon = data.icon;
						if (!Type.InstanceOf(ImageMetadata).is(icon) && icon && SystemIcon.hasOwnProperty(icon.toUpperCase())) {
							icon = SystemIcon[icon.toUpperCase()];
						}

						if (Type.InstanceOf(ImageMetadata).is(icon)) {
							items.push(new Image({
								image: icon,
								presentation: true,
								classList: cssClassNames.ASSISTIVE_CONTENT_ICON
							}));
							hasIcon = true;
						} else {
							Log.warning('Icon name: "', data.icon, '" is not available in ImageSet');
						}
					}

					if (data.text.length > 0) {
						if (checkHtml(data.text)) {
							var text = Dom.span(cssClassNames.ASSISTIVE_CONTENT_TEXT);
							text.innerHTML = data.text;
							items.push(text);
						} else {
							Log.warning('Forbidden HTML content.');
						}
					}
				}

				var content = Dom.div([cssClassNames.ASSISTIVE_CONTENT], items);

				if (Type.Value.is(data.width)) {
					content.classList.add(cssClassNames.ASSISTIVE_CONTENT_WIDTH + data.width.toLowerCase());
				}

				if (Type.Value.is(data.height)) {
					content.classList.add(cssClassNames.ASSISTIVE_CONTENT_HEIGHT + data.height.toLowerCase());
				}
				content.classList.toggle(cssClassNames.ASSISTIVE_CONTENT_DATA, !Array.isEmpty(items) || Type.Value.is(data.height));
				content.classList.toggle(cssClassNames.ASSISTIVE_CONTENT_NO_ICON, !hasIcon);

				return content;
			}
		}
	});

	var cssClassNames = Object.freeze({
		ASSISTIVE_CONTENT: 'n-f-field_assistive-content',
		ASSISTIVE_CONTENT_DATA: 'n-f-field_assistive-content__data',
		ASSISTIVE_CONTENT_NO_ICON: 'n-f-field_assistive-content--no-icon',
		ASSISTIVE_CONTENT_TEXT: 'n-f-field_assistive-content__text',
		ASSISTIVE_CONTENT_ICON: 'n-f-field_assistive-content__icon',
		ASSISTIVE_CONTENT_WIDTH: 'n-f-size-width__field--',
		ASSISTIVE_CONTENT_HEIGHT: 'n-f-field_assistive-content__height--'
	});

	function checkHtml(html) {
		return Type.Value.is(html) && !/<(script|html|iframe)/.test(html);
	}

	return AssistiveContent;
});
