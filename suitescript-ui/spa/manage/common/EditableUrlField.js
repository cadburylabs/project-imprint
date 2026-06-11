define('n/suitescript-ui/spa/manage/common/EditableUrlField', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/widgets/Component',
	'n/ui/widgets/toolkit/Link',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/Text',
	'n/ui/widgets/toolkit/TextBox',
	'n/suitescript-ui/spa/manage/common/EditableComponent'
], function (
	Class,
	Object,
	ImmutableObject,
	Component,
	Link,
	StackPanel,
	Text,
	TextBox,
	EditableComponent
) {
	'use strict';

	var EditableUrlField = Class.create({
		extend: EditableComponent,
		automationId: 'EditableUrlField',

		/**
		 * @typedef {Component.Options} EditableUrlField.Options
		 */

		/**
		 * @class EditableUrlField
		 * @extends EditableComponent
		 * @param {EditableUrlField.Options} [options] EditableUrlField options
		 */
		initialize: function EditableUrlField(options) {
			options = ImmutableObject.merge(defaultOptions, options || {});
			EditableUrlField.$super.call(this, options);
			this._urlPrefix = options.urlPrefix;
			this._maxLength = options.maxLength;
			this._maxLengthIndicator = options.maxLengthIndicator;
			this._formatter = options.formatter;
		},

		/** @lends EditableUrlField# */
		properties: {},

		/** @lends EditableUrlField# */
		methods: {
			_onChange: function () {
				var formattedText = this._formatter(this._getSelectedValueUrlArea());
				this._setValueInEditableComponent(formattedText);
			},
			_createUrlArea: function () {
				this._editComponentPlaceholder = new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					alignment: StackPanel.Alignment.CENTER
				});
				this.editComponent = new TextBox({
					automationId: this.automationId+'-editable-field',
					text: this.selectedValue,
					type: TextBox.Type.URL,
					maxLength: this._maxLength,
					maxLengthIndicator: this._maxLengthIndicator,
					classList: EditableComponent.CssClass.EDITABLE_FIELD
				});
				this.editComponent.on(Component.Event.FOCUS_OUT, this._onChange.bind(this));

				this._editComponentPlaceholder.add(new Text(
					{
						text: this._urlPrefix,
						wrap: false
					}));
				this._editComponentPlaceholder.add(this.editComponent);

				return this._editComponentPlaceholder;
			},
			_getSelectedValueUrlArea: function () {
				return this.editComponent.text;
			},
			_getSelectedDisplayUrlArea: function () {
				return this._urlPrefix+this._getSelectedValueUrlArea();
			}
		},

		/** @lends EditableUrlField# */
		overrides: {
			_setNonEditableValue: function (value) {
				this._nonEditableArea.url = value;
				this._nonEditableArea.content = value;
			},
			_setValueInEditableComponent: function (value) {
				this.editComponent.text = value;
			},
			_createEditableArea: function (actionButtons) {
				var editableArea = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL
				});
				editableArea.add(this._createUrlArea());
				editableArea.add(actionButtons);

				return editableArea;
			},
			_createNonEditableArea: function () {
				this._nonEditableArea = new Link({
					automationId: this.automationIdNonEditableArea,
					content: this._getDisplayValue(),
					url: this._getDisplayValue(),
					target: Link.Target.BLANK,
					classList: [CssClass.LINK]
				});

				return this._nonEditableArea;
			},
			_getDisplayValue: function () {
				return this._getSelectedDisplayUrlArea();
			},
			_getSelectedValue: function () {
				return this._getSelectedValueUrlArea();
			},
			_setValid: function (isValid) {
				this.editComponent.valid = isValid;
			},
			_onChangeEventName: function () {
				return TextBox.Event.TEXT_CHANGED;
			},
			_onFocusOutEventName: function () {
				return Component.Event.FOCUS_OUT;
			}
		},
		static: {
			CssClass: Object.freeze({
				LINK: 'n-ssui-spa-manage-common-link'
			})
	}
	});

	var CssClass = EditableUrlField.CssClass;

	var defaultOptions = Object.freeze({
		urlPrefix: '',
		maxLength: null,
		maxLengthIndicator: false,
		formatter: function (value) {
			return value;
		}
	});

	return EditableUrlField;
});