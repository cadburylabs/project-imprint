define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalFieldPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/Service',
	'n/ui/widgets/helper/Loader',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/manage/common/ComponentWithHelp',
	'n/suitescript-ui/spa/manage/common/SpinnerComponent',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalField'
], function (
	Class,
	Object,
	Presenter,
	Service,
	Loader,
	StackPanel,
	ComponentWithHelp,
	SpinnerComponent,
	CenterLinkModalField
) {
	'use strict';

	var CenterLinkModalFieldPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class CenterLinkModalFieldPresenter
		 * @extends Presenter
		 */
		initialize: function CenterLinkModalFieldPresenter(options) {
			CenterLinkModalFieldPresenter.$super.call(this, options);
			this._createLoader();
			this._createComponentPlaceholder();
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends CenterLinkModalFieldPresenter# */
		properties: {},

		/** @lends CenterLinkModalFieldPresenter# */
		methods: {
			_setSpinnerVisibile: function (visible) {
				if (visible)
				{
					this._componentPlaceholder.visible = !visible;
					this._loader.visible = visible;
				}
				else {
					this._loader.visible = visible;
					this._componentPlaceholder.visible = !visible
				}
			},
			_showSpinner: function () {
				this._setSpinnerVisibile(true);
			},
			_hideSpinner: function () {
				this._setSpinnerVisibile(false);
			},
			_createLoader: function () {
				this._loader = SpinnerComponent.new({type: Loader.Icon.HORIZONTAL});
				return this._loader;
			},
			_setFieldError: function (value) {
				var errorMessage = '';
				if (value !== '') {
					if (value.isTranslated) {
						errorMessage = value.message
					} else errorMessage = this.i18n.get(value.message);
				}
				this._customContent.errorMessage = errorMessage;
			},
			_createComponentPlaceholder: function () {
				this._componentPlaceholder = new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL
				});
			},
			_createField: function (header, component, automationId, fieldId) {

				this._customContent = new CenterLinkModalField({
					component: component,
					automationId: automationId
				});

				this._componentPlaceholder.add({
					component: this._customContent,
					options: {
						grow: 1
					}
				});

				var panel = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL,
					alignment: StackPanel.Alignment.STRETCH,
					items: [
						this._loader,
						this._componentPlaceholder
					]
				});

				return new ComponentWithHelp({
					component: panel,
					label: header,
					helpService: this._helpService,
					fieldId: fieldId,
					labelPlacement: ComponentWithHelp.labelPlacement.TOP,
					automationId: AutomationIds.FIELD_HEADER_PREFIX + automationId,
					type: ComponentWithHelp.TYPE.LABEL
				});
			}
		},

		/** @lends CenterLinkModalFieldPresenter# */
		overrides: {},
		static: {
			AutomationIds: Object.freeze({
				FIELD_HEADER_PREFIX: "manage-spa-configuration-center-link-modal-field-header-",
			})
		}
	});

	var AutomationIds = CenterLinkModalFieldPresenter.AutomationIds;

	return CenterLinkModalFieldPresenter;
});