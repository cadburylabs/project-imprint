define('n/suitescript-ui/spa/manage/common/EditableTextAreaField', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/widgets/Component',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/TextArea',
	'n/suitescript-ui/spa/manage/common/EditableComponent'
], function (
	Class,
	Object,
	ImmutableObject,
	Component,
	StackPanel,
	TextArea,
	EditableComponent
) {
	'use strict';

	var EditableTextAreaField = Class.create({
		extend: EditableComponent,
		automationId: 'EditableTextAreaField',

		/**
		 * @typedef {Component.Options} EditableTextAreaField.Options
		 */

		/**
		 * @class EditableTextAreaField
		 * @extends Component
		 * @param {EditableTextAreaField.Options} [options] EditableTextAreaField options
		 */
		initialize: function EditableTextAreaField(options) {
			options = ImmutableObject.merge(defaultOptions, options || {});
			EditableTextAreaField.$super.call(this, options);

			this._maxLength = options.maxLength;
		},

		/** @lends EditableTextAreaField# */
		properties: {},

		/** @lends EditableTextAreaField# */
		methods: {
			_adaptValueForTextArea: function (value) {
				return value?value:"";
			},
			_createTextArea: function () {
				this.editComponent = new TextArea({
					automationId: this.automationId+'-editable-field',
					text: this._adaptValueForTextArea(this.selectedValue),
					maxLength: this._maxLength,
					classList: EditableComponent.CssClass.EDITABLE_FIELD
				});

				return this.editComponent;
			},
			_getSelectedValueTextArea: function () {
				return this.editComponent.text;
			}
		},

		/** @lends EditableTextAreaField# */
		overrides: {
			_setValueInEditableComponent: function (value) {
				this.editComponent.text = this._adaptValueForTextArea(value);
			},
			_createEditableArea: function (actionButtons) {
				var editableArea = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL
				});
				editableArea.add(this._createTextArea());
				editableArea.add(actionButtons);

				return editableArea;
			},
			_getDisplayValue: function () {
				return this._getSelectedValueTextArea();
			},
			_getSelectedValue: function () {
				return this._getSelectedValueTextArea();
			},
			_setValid: function (isValid) {
				this.editComponent.valid = isValid;
			},
			_onChangeEventName: function () {
				return TextArea.Event.TEXT_CHANGED;
			},
			_onFocusOutEventName: function () {
				return Component.Event.FOCUS_OUT;
			}
		}
	});

	var defaultOptions = Object.freeze({
		maxLength: null
	});

	return EditableTextAreaField;
});