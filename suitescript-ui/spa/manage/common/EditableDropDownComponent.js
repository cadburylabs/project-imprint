define('n/suitescript-ui/spa/manage/common/EditableDropDownComponent', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/widgets/data/ArrayDataSource',
	'n/ui/widgets/toolkit/Dropdown',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/manage/common/EditableComponent'
], function (
	Class,
	Object,
	ImmutableObject,
	ArrayDataSource,
	Dropdown,
	StackPanel,
	EditableComponent
) {
	'use strict';

	var EditableDropDownComponent = Class.create({
		extend: EditableComponent,
		automationId: 'EditableDropDownComponent',

		/**
		 * @typedef {Component.Options} EditableDropDownComponent.Options
		 */

		/**
		 * @class EditableDropDownComponent
		 * @extends EditableComponent
		 * @param {EditableDropDownComponent.Options} [options] EditableDropDownComponent options
		 */
		initialize: function EditableDropDownComponent(options) {
			options = ImmutableObject.merge(defaultOptions, options || {});
			EditableDropDownComponent.$super.call(this, options);

			this._valueMember = options.valueMember;
			this._displayMember = options.displayMember;
			this._sourceData = options.source;
		},

		/** @lends EditableDropDownComponent# */
		properties: {},

		/** @lends EditableDropDownComponent# */
		methods: {
			_getSelectedItemForDropDown: function (value) {
				var that = this;
				return this._sourceData.filter(
					function (element) {
						return element[that._valueMember] == value;
					})[0];
			},

			_createDropdown: function () {
				var dataSource = new ArrayDataSource(this._sourceData);

				this.editComponent = new Dropdown({
					automationId: this.automationId + '-editable-field',
					dataSource: dataSource,
					valueMember: this._valueMember,
					displayMember: this._displayMember,
					selectedItem: this._getSelectedItemForDropDown(this.selectedValue),
					classList: EditableComponent.CssClass.EDITABLE_FIELD
				});

				return this.editComponent;
			},
			_getSelectedValueFromDropDown: function (field) {
				var selectedItem = this.editComponent.selectedItem;
				var selectedItemText = "";
				if (selectedItem) {
					selectedItemText = selectedItem[field];
				}
				return selectedItemText;
			}
		},

		/** @lends EditableDropDownComponent# */
		overrides: {
			_setValueInEditableComponent: function (value) {
				this.editComponent.selectedItem = this._getSelectedItemForDropDown(value);
			},
			_createEditableArea: function (actionButtons) {
				var editableArea = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL
				});
				editableArea.add(this._createDropdown());
				editableArea.add(actionButtons);

				return editableArea;
			},
			_getDisplayValue: function () {
				return this._getSelectedValueFromDropDown(this._displayMember);
			},
			_getSelectedValue: function () {
				return this._getSelectedValueFromDropDown(this._valueMember);
			},
			_setValid: function (isValid) {
				this.editComponent.valid = isValid;
			},
			_onChangeEventName: function () {
				return Dropdown.Event.SELECTED_ITEM_CHANGED;
			}
		}
	});

	var defaultOptions = Object.freeze({
		source: []
	});

	return EditableDropDownComponent;
});