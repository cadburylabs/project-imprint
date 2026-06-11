define('n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/listItems/ItemComponent', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/widgets/Component',
	'n/ui/widgets/helper/Dom',
	'n/ui/widgets/toolkit/Badge'
], function (
	Class,
	Object,
	ImmutableObject,
	Component,
	Dom,
	Badge
) {
	'use strict';

	var ItemComponent = Class.create({
		extend: Component,
		automationId: 'ErrorNotificationsItemComponent',

		/**
		 * @typedef {Component.Options} ItemComponent.Options
		 */

		/**
		 * @class ItemComponent
		 * @extends Component
		 * @param {String} options.labelName
		 * @param {String} options.automationId
		 */
		initialize: function ItemComponent(options) {
			options = ImmutableObject.merge(defaultOptions, options || {});
			this._labelName = options.labelName;
			this._automationId = options.automationId
			ItemComponent.$super.call(this, options);
		},

		/** @lends ItemComponent# */
		properties: {
			labelName: {
				writable: true,
				afterChange: function (oldValue, currentValue) {
					if (oldValue !== currentValue) {
						this._setLabelName(currentValue);
					}
				}
			}
		},

		/** @lends ItemComponent# */
		methods: {
			_setLabelName: function (value) {
				if (this._textComponent !== undefined) {
					this._textComponent.text = value;
				}
			}
		},

		/** @lends ItemComponent# */
		overrides: {
			_onRender: function () {
				this._textComponent = new Badge({
					content: this._labelName,
					type: Badge.Type.SUBTLE,
					automationId: this._automationId
				});

				return Dom.div(CssClass.BUBBLE, this._textComponent);
			}
		},
		static: {
			CssClass: Object.freeze({
				BUBBLE: 'n-ssui-spa-manage-item-bubble'
			})
		}
	});

	var defaultOptions = Object.freeze({});

	var CssClass = ItemComponent.CssClass;
	return ItemComponent;
});