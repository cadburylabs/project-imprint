define('n/suitescript-ui/spa/manage/common/EditableComponent', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/widgets/Component',
	'n/ui/widgets/helper/Dom',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Button',
	'n/ui/widgets/toolkit/Image',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/Text',
	'n/ui/widgets/tooltip/Tooltip',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/ComponentWithHelp'
], function (
	Class,
	Object,
	ImmutableObject,
	Component,
	Dom,
	SystemIcon,
	Button,
	Image,
	StackPanel,
	Text,
	Tooltip,
	TranslationKeys,
	ComponentWithHelp
) {
	'use strict';

	var EditableComponent = Class.create({
		extend: Component,

		/**
		 * @typedef {Component.Options} EditableComponent.Options
		 */

		/**
		 * @class EditableComponent
		 * @extends Component
		 * @param {EditableComponent.Options} [options] EditableComponent options
		 * @param {Boolean} [options.mandatory] Mandatory field boolean
		 */
		initialize: function EditableComponent(options) {
			options = ImmutableObject.merge(defaultOptions, options || {});
			EditableComponent.$super.call(this, options);

			this._selectedValue = options.selectedValue;
			this._originalValue = options.selectedValue;
			this._fieldTitle = options.title;
			this._onSave = options.onSave;
			this._automationId = options.automationId;
			this._serverErrorProcessor = options.serverErrorProcessor;
			this._validateFunction = options.onValidate;
			this._editable = options.editable;
			this._mandatoryField = options.mandatory;
			this._helpService = options.helpService;
			this._fieldId = options.fieldId;
			this._parentId = options.parentId;
			this._variantId = options.variantId;
		},

		/** @lends EditableComponent# */
		properties: {
			/**
			 * Returns the selected value
			 * @type {string}
			 */
			selectedValue: {
				get: function () {
					return this._selectedValue;
				}
			},
			/**
			 * Returns the selected value
			 * @type {string}
			 */
			automationId: {
				get: function () {
					return this._automationId;
				}
			},
			/**
			 * Returns the selected value
			 * @type {string}
			 */
			automationIdNonEditableArea: {
				get: function () {
					return this.automationId + '-non-editable-field';
				}
			},
			/**
			 * Returns/sets the editable component
			 * @type {StackPanel}
			 */
			editComponent: {
				get: function () {
					return this._editComponent;
				},
				set: function (value) {
					this._editComponent = value;
				}
			},
			editable: {
				writable: true,
				afterChange: function (oldValue, newValue) {
					if (this._editing && !newValue) {
						this._setEditMode(newValue);
					}
					this._field.editable = newValue;
				}
			}
		},

		/** @lends EditableComponent# */
		methods: {
			/**
			 * Sets the Value in the editable component.
			 * @abstract
			 * @param {string} selectedValue
			 *
			 * @example
			 * <pre>
			 * _setValueInEditableComponent: function (value) {
			 *     this._editComponent.selectedItem = value
			 * }
			 * </pre>
			 */
			_setValueInEditableComponent: function (selectedValue) {
				throw "Child Component must implement _setValueInEditableComponent method";
			},

			/**
			 * Sets the visibility of the elements
			 *
			 * @param editing {Boolean}
			 */
			_setEditMode: function (editing) {
				this._nonEditableArea.visible = !editing;
				this._editableArea.visible = editing;
				if (this._field) {
					this._field.editing = editing;
				}
			},

			/**
			 * Returns the Action Buttons
			 *
			 * @returns {StackPanel}
			 */
			_createActionButtons: function () {
				var that = this;
				this._buttons = new StackPanel({orientation: StackPanel.Orientation.HORIZONTAL});
				this._buttonSave = new Button({
					automationId: that._automationId + '-save',
					classList: CssClass.SAVE_BUTTON,
					label: that.i18n.get(TranslationKeys.SPA_SAVE_BUTTON),
					hierarchy: Button.Hierarchy.PRIMARY,
					action: that._onSaveAction.bind(this)
				});
				this._buttons.add(this._buttonSave);
				this._buttons.add(new Button({
					automationId: that._automationId + '-cancel',
					label: that.i18n.get(TranslationKeys.SPA_CANCEL_BUTTON),
					action: that._onCancelAction.bind(this)
				}));

				return this._buttons;
			},

			_enableButtons: function () {
				this._buttons.enabled = true;
			},

			_disableButtons: function () {
				this._buttons.enabled = false;
			},

			_enableSaveButton: function () {
				this._buttonSave.enabled = true;
			},

			_disableSaveButton: function () {
				this._buttonSave.enabled = false;
			},

			/**
			 * Sets the Value in the non editable component.
			 * @abstract
			 * @param {string} value
			 *
			 * @example
			 * <pre>
			 * _setValueInEditableComponent: function (value) {
			 *     this._nonEditableArea.text = value;
			 * }
			 * </pre>
			 */
			_setNonEditableValue: function (value) {
				if (value == "") {
					value = "—";
				}
				this._nonEditableArea.text = value;
			},

			/**
			 * Callback for the Save Action
			 *
			 * @param btnArgs {Object} button click arguments
			 */
			_onSaveAction: function (btnArgs) {
				this._disableButtons();
				var that = this;
				var newValue = this._getSelectedValue();
				if (newValue !== this._originalValue) {
					this._onSave(newValue).then(function () {
						that._setNonEditableValue(that._getDisplayValue());
						that._resetSelectedValue(newValue);
						that._setEditMode(false);
					}).catch(function (ex) {
						that._setError(that._serverErrorProcessor(ex));
					});
				} else {
					this._onCancelAction(btnArgs);
				}

				this._enableButtons();
			},

			/**
			 * Callback for the Cancel Action
			 *
			 * @param btnArgs {Object} button click arguments
			 */
			_onCancelAction: function (btnArgs) {
				this._setEditMode(false);
				this._setValueInEditableComponent(this._originalValue);
			},

			/**
			 * Sets both selectedValue and originalValue
			 * to the provided value
			 *
			 * @param value {Object} new selected value
			 */
			_resetSelectedValue: function (value) {
				this._selectedValue = value;
				this._originalValue = value;
			},

			/**
			 * Creates and returns the non-editable area
			 *
			 * @abstract
			 * @returns {StackPanel}
			 */
			_createNonEditableArea: function () {
				this._nonEditableArea = new Text({
					automationId: this.automationIdNonEditableArea,
					whitespace: true
				});
				this._setNonEditableValue(this._getDisplayValue());

				return new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					alignment: StackPanel.Alignment.CENTER,
					items: [this._nonEditableArea]
				});
			},

			/**
			 * Sets the Value in the editable component.
			 * @abstract
			 * @param actionButtons {StackPanel} Action Buttons
			 * @returns {StackPanel}
			 *
			 * @example
			 * <pre>
			 * _createEditableArea: function (actionButtons) {
			 *      var editableArea = new StackPanel({
			 *      orientation: StackPanel.Orientation.VERTICAL,
			 *      visible: false
			 *  });
			 *  editableArea.add(this._createSpecificComponent);
			 *  editableArea.add(actionButtons);
			 *
			 *  return editableArea;
			 * }
			 * </pre>
			 */
			_createEditableArea: function (actionButtons) {
				throw "Child Component must implement _createEditableArea method";
			},

			/**
			 * Returns the DisplayValue from the component
			 * @abstract
			 * @returns {string}
			 */
			_getDisplayValue: function () {
				throw "Child Component must implement _getDisplayValue method";
			},

			/**
			 * Returns the SelectedValue from the component
			 * @abstract
			 * @returns {string}
			 */
			_getSelectedValue: function () {
				throw "Child Component must implement _getSelectedValue method";
			},

			/**
			 * Sets the 'valid' property in the editable component.
			 * @abstract
			 * @param isValid {Boolean} Action Buttons
			 *
			 * @example
			 * <pre>
			 * _setValid: function (isValid) {
			 *      this._editComponent.valid = isValid;
			 * }
			 * </pre>
			 */
			_setValid: function (isValid) {
				throw "Child Component must implement _setValid method";
			},

			/**
			 * Returns the onChange event name of the editable component
			 * @abstract
			 *
			 * @returns {string}
			 *
			 * @example
			 * <pre>
			 * _onChangeEventName: function () {
			 *      return TextBox.Event.TEXT_CHANGED;
			 * }
			 * </pre>
			 */
			_onChangeEventName: function () {
				return undefined;
			},

			/**
			 * Returns the onFocusOut event name of the editable component
			 * @abstract
			 *
			 * @returns {string}
			 *
			 * @example
			 * <pre>
			 * _onChangeEventName: function () {
			 *      return Component.Event.FOCUS_OUT;
			 * }
			 * </pre>
			 */
			_onFocusOutEventName: function () {
				return undefined;
			},

			_createErrorComponent: function () {
				this._errorTooltip = new Tooltip({
					closeStrategy: Tooltip.CloseStrategy.focusedOrOver(),
					automationId: 'Error-tooltip'
				});

				this._errorComponent = new Image({
					image: SystemIcon.ERROR.withCaption("Error"),
					tooltip: this._errorTooltip,
					automationId: 'Error-image',
					classList: [CssClass.ERROR_COMPONENT],
					visible: false
				});

				return this._errorComponent;
			},

			_setError: function (errorMessage) {
				this._disableSaveButton();
				this._errorTooltip.content = errorMessage;
				this._setValid(false);
				this._errorComponent.visible = true;
			},

			_removeError: function () {
				this._errorTooltip.content = "";
				this._setValid(true);
				this._errorComponent.visible = false;
				this._enableSaveButton();
			},

			_bindEditComponentEvents: function () {
				var onChangeEventName = this._onChangeEventName();
				if (onChangeEventName) {
					this.editComponent.on(onChangeEventName, this._removeError.bind(this));
				}

				var onFocusOutEventName = this._onFocusOutEventName();
				if (onFocusOutEventName) {
					this.editComponent.on(onFocusOutEventName, this._onValidate.bind(this));
				}
			},

			_createEditableBlock: function () {
				var actionButtons = this._createActionButtons();
				this._editableArea = this._createEditableArea(actionButtons);
				this._bindEditComponentEvents();


				return new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					alignment: StackPanel.Alignment.START,
					justification: StackPanel.Justification.START,
					items: [this._editableArea, this._createErrorComponent()]
				});
			},

			_onValidate: function () {
				var validationResult = this._validateFunction(this._getSelectedValue());
				if (validationResult != '') {
					this._setError(validationResult);
				}
			},
			_getHeaderText: function () {
				var text = this._fieldTitle;
				if (this._mandatoryField && this._editable) {
					text += Constants.MANDATORY_CHAR;
				}
				return text;
			},
			_buildComponent: function () {
				var panel = new StackPanel({orientation: StackPanel.Orientation.VERTICAL});
				panel.add(this._createEditableBlock());
				panel.add(this._createNonEditableArea());

				return panel;
			}
		},

		/** @lends EditableComponent# */
		overrides: {
			_onRender: function () {
				this._field = new ComponentWithHelp({
					ariaLabel: this._fieldTitle,
					automationId: this._automationId,
					component: this._buildComponent(),
					label: this._getHeaderText(),
					helpService: this._helpService,
					fieldId: this._fieldId,
					labelPlacement: ComponentWithHelp.labelPlacement.TOP,
					saveAction: this._setEditMode.bind(this, true),
					editable: this._editable
				});
				this._setEditMode(false);
				return Dom.div(CssClass.ROOT, this._field);
			}
		},
		static: {
			CssClass: Object.freeze({
				ERROR_COMPONENT: 'n-ssui-spa-manage-error-component',
				SAVE_BUTTON: 'n-ssui-spa-manage-editable-field-save-button',
				EDITABLE_FIELD: 'n-ssui-spa-manage-editable-field'
			}),
			Constants: Object.freeze({
				MANDATORY_CHAR: " *"
			})
		}
	});

	var CssClass = EditableComponent.CssClass;
	var Constants = EditableComponent.Constants;

	var defaultOptions = Object.freeze({
		selectedValue: null,
		mandatory: false,
		serverErrorProcessor: function (value) {
			return value;
		},
		onValidate: function (value) {
			return '';
		},
		editable: true
	});

	return EditableComponent;
});