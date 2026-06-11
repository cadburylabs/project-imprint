define('n/suitescript-ui/spa/manage/common/ComponentWithHelp', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/widgets/Component',
	'n/ui/widgets/helper/Dom',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Button',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/layout/GapSize',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/common/FieldWithHelp'
], (
	Class,
	Object,
	ImmutableObject,
	Component,
	Dom,
	SystemIcon,
	Button,
	StackPanel,
	GapSize,
	Constants,
	FieldWithHelp
) => {
	'use strict';

	const ComponentWithHelp = Class.create({
		extend: Component,
		automationId: 'ComponentFLH',

		/**
		 * @typedef {Component.Options} ComponentFLH.Options
		 */

		/**
		 * @class ComponentFLH
		 * @extends Component
		 * @param {ComponentFLH.Options} [options] ComponentFLH options
		 * @param {String} options.label
		 * @param {Component} options.component
		 * @param {FieldHelpService} options.helpService
		 * @param {String} options.fieldId
		 * @param {ComponentWithHelp.LABEL_PLACEMENT} options.labelPlacement
		 * @param {String} options.automationId
		 * @param {String} options.ariaLabel
		 * @param {Function} options.saveAction
		 * @param {ComponentWithHelp.TYPE} [options.type = ComponentWithHelp.TYPE.TEXT] text/label
		 * @param {Boolean} options.editable
		 */
		initialize: function ComponentWithHelp(options) {
			options = ImmutableObject.merge(defaultOptions, options || {});
			this.constructor.$super.call(this, options);
			this._component = options.component;
			this._label = options.label;
			this._helpService = options.helpService;
			this._fieldId = options.fieldId;
			this._labelPlacement = options.labelPlacement;
			this._orientation = this._stackPanelOrientation(options.labelPlacement);
			this._saveAction = options.saveAction;
			this._automationId = options.automationId;
			this._ariaLabel = options.ariaLabel;
			this._type = options.type;
			this._editing = options.editing;
			this._editable = options.editable;
		},

		/** @lends ComponentFLH# */
		properties: {
			editing: {
				writable: true,
				afterChange: function(oldValue, currentValue) {
					if (this._editable) {
						this._editButton.visible = !currentValue;
					}
					else {
						console.error(this._label + " component is not editable.");
					}
				}
			},
			editable: {
				writable: true,
				afterChange: function(oldValue, newValue) {
					this._editButton.visible = newValue;
				}
			}
		},

		/** @lends ComponentFLH# */
		methods: {
			_buildHeader: function () {
				var label = new FieldWithHelp({
					text: this._label.toUpperCase(),
					helpService: this._helpService,
					fieldId: this._fieldId,
					parentId: Constants.FLH.PARENT_ID,
					type: this._type,
					automationId: this._automationId
				});

				var header = new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					alignment: StackPanel.Alignment.CENTER
				});
				header.add(label);
				header.add(this._buildEditButton());
				return header;
			},
			_buildEditButton: function () {
				this._editButton = new Button({
					ariaLabel: this._ariaLabel,
					automationId: this._automationId + '-edit',
					type: Button.Type.PURE,
					icon: SystemIcon.EDIT,
					action: this._saveAction,
					visible: (this._editable && !this._editing)
				});

				return this._editButton;
			},
			_stackPanelOrientation: function (labelPlacement) {
				if (labelPlacement === ComponentWithHelp.labelPlacement.RIGHT) return StackPanel.Orientation.HORIZONTAL;
				return StackPanel.Orientation.VERTICAL;
			},
			_getPanelOptions: function () {
				if (this._labelPlacement === ComponentWithHelp.labelPlacement.RIGHT) {
					return {
						orientation: this._orientation,
						alignment: StackPanel.Alignment.CENTER,
						itemGap: GapSize.SMALL
					};
				}

				return {
					orientation: this._orientation
				};
			}
		},

		/** @lends ComponentFLH# */
		overrides: {
			_onRender() {
				var header = this._buildHeader();
				var panel = new StackPanel(this._getPanelOptions());

				if (this._labelPlacement === ComponentWithHelp.labelPlacement.RIGHT) {
					panel.add(this._component);
					panel.add(header);
				}
				else {
					panel.add(header);
					panel.add(this._component);
				}
				return Dom.div(CssClass.ROOT, panel);
			}
		},
		static: {
			labelPlacement: Object.freeze({
				TOP: 'top',
				RIGHT: 'right'
			}),
			TYPE: FieldWithHelp.TYPE
		}
	});

	const CssClass = Object.freeze({
		ROOT: 'n-w-componentflh'
	});

	const defaultOptions = Object.freeze({
		labelPlacement: ComponentWithHelp.labelPlacement.RIGHT,
		saveAction: undefined,
		editing: false,
		editable: false
	});

	return ComponentWithHelp;
});