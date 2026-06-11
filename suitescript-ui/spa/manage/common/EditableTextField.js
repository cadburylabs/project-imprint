define('n/suitescript-ui/spa/manage/common/EditableTextField', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/widgets/Component',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/Text',
	'n/ui/widgets/toolkit/TextBox',
	'n/suitescript-ui/spa/manage/common/EditableComponent'
], function (
	Class,
	Object,
	ImmutableObject,
	Component,
	StackPanel,
	Text,
	TextBox,
	EditableComponent
) {
	'use strict';

	var EditableTextField = Class.create({
		extend: EditableComponent,
		automationId: 'EditableTextField',

		/**
		 * @typedef {Component.Options} EditableTextField.Options
		 */

		/**
		 * @class EditableTextField
		 * @extends EditableComponent
		 * @param {EditableTextField.Options} [options] EditableTextField options
		 */
		initialize: function EditableTextField(options) {
			options = ImmutableObject.merge(defaultOptions, options || {});
			EditableTextField.$super.call(this, options);
			this._prefix = options.prefix;
			this._maxLength = options.maxLength;
			this._maxLengthIndicator = options.maxLengthIndicator;
			this._formatter = options.formatter;
		},

		/** @lends EditableTextField# */
		properties: {},

		/** @lends EditableTextField# */
		methods: {
			_onChange: function () {
				var formattedText = this._formatter(this._getSelectedValueTextBox());
				this._setValueInEditableComponent(formattedText);
			},
			_createTextBox: function () {
				this._editComponentPlaceholder = new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					alignment: StackPanel.Alignment.CENTER,
					itemGap: StackPanel.GapSize.SMALL
				});

				if (this._prefix !== "") {
					this._editComponentPlaceholder.add(
						new Text({
							text: this._prefix,
							wrap: false
						})
					);
				}

				this.editComponent = new TextBox({
					text: this.selectedValue,
					automationId: this.automationId+'-editable-field',
					maxLength: this._maxLength,
					maxLengthIndicator: this._maxLengthIndicator,
					classList: EditableComponent.CssClass.EDITABLE_FIELD
				});

				this.editComponent.on(Component.Event.FOCUS_OUT, this._onChange.bind(this));

				this._editComponentPlaceholder.add(this.editComponent);

				return this._editComponentPlaceholder;
			},
			_getSelectedValueTextBox: function () {
				return this.editComponent.text;
			},
			_getDisplayValueTextBox: function () {
				return this._prefix+this._getSelectedValueTextBox();
			}
		},

		/** @lends EditableTextField# */
		overrides: {
			_setValueInEditableComponent: function (value) {
				this.editComponent.text = value;
			},
			_createEditableArea: function (actionButtons) {
				var editableArea = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL
				});
				editableArea.add(this._createTextBox());
				editableArea.add(actionButtons);

				return editableArea;
			},
			_getDisplayValue: function () {
				return this._getDisplayValueTextBox();
			},
			_getSelectedValue: function () {
				return this._getSelectedValueTextBox();
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
		}
	});

	var defaultOptions = Object.freeze({
		prefix: '',
		maxLength: null,
		maxLengthIndicator: false,
		formatter: function (value) {
			return value;
		}
	});

	return EditableTextField;
});