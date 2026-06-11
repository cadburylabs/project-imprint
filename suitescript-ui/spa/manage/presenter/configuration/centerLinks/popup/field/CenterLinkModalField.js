define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalField', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/widgets/Component',
	'n/ui/widgets/helper/Dom',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Image',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/tooltip/Tooltip'
], function (
	Class,
	Object,
	ImmutableObject,
	Component,
	Dom,
	SystemIcon,
	Image,
	StackPanel,
	Tooltip
) {
	'use strict';

	var CenterLinkModalField = Class.create({
		extend: Component,
		automationId: "CenterLinkModalField",
		/**
		 * @class CenterLinkModalField
		 *
		 * @param {Object} options
		 * @param {Component} options.component
		 * @param {String} options.automationId
		 */
		initialize: function CenterLinkModalField(options) {
			options = ImmutableObject.merge(defaultOptions, options || {});
			CenterLinkModalField.$super.call(this, options);
			this._errorMessage = null;
			this._component = options.component;
			this._automationId = options.automationId;
		},

		/** @lends CenterLinkModalField# */
		properties: {
			errorMessage: {
				writable: true,
				afterChange: function(oldValue, currentValue) {
					this._setError(currentValue);
				}
			}
		},

		/** @lends CenterLinkModalField# */
		methods: {
			_setError: function (value) {
				this._errorMessage = value;
				if (value === null || value === '')
					this._removeError();
				else
					this._showError();
			},
			_showError: function () {
				this._errorTooltip.content = this._errorMessage;
				this._errorComponent.visible = true;
				this._component.valid = false;
			},
			_removeError: function () {
				this._errorTooltip.content = "";
				this._errorComponent.visible = false;
				this._component.valid = true;
			},
			_createErrorComponent: function () {
				this._errorTooltip = new Tooltip({
					closeStrategy: Tooltip.CloseStrategy.focusedOrOver(),
					automationId: AutomationIds.ERROR_TOOLTIP + this._automationId
				});

				this._errorComponent = new Image({
					image: SystemIcon.ERROR.withCaption('Error'),
					tooltip: this._errorTooltip,
					automationId: AutomationIds.ERROR_ICON + this._automationId,
					ariaLabel: AutomationIds.ERROR_ICON + this._automationId,
					classList: [CssClass.ERROR_COMPONENT],
					visible: false
				});

				return this._errorComponent;
			}},

		/** @lends CenterLinkModalField# */
		overrides: {
			_onRender: function () {
				this._field = new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					alignment: StackPanel.Alignment.CENTER,
					justification: StackPanel.Justification.START,
					items: [
						{
							component: this._component,
							options: {
								grow: 1
							}
						},
						this._createErrorComponent()]
				});
				return Dom.div(CssClass.ROOT, this._field);
			}
		},
		static: {
			CssClass: Object.freeze({
				ERROR_COMPONENT: 'n-ssui-spa-manage-error-component'
			}),
			AutomationIds: Object.freeze({
				FIELD: "manage-spa-configuration-center-link-modal-field-",
				ERROR_TOOLTIP: "manage-spa-configuration-center-link-modal-field-error-tooltip-",
				ERROR_ICON: "manage-spa-configuration-center-link-modal-field-error-icon-"
			})
		}
	});

	var CssClass = CenterLinkModalField.CssClass;
	var AutomationIds = CenterLinkModalField.AutomationIds;

	var defaultOptions = Object.freeze({
	});

	return CenterLinkModalField;
});