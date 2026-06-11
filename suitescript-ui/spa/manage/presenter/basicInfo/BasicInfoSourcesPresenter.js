define('n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoSourcesPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/Service',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Button',
	'n/ui/widgets/toolkit/GridPanel',
	'n/ui/widgets/toolkit/Heading',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/Text',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/ComponentWithHelp',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/common/UrlHelper'
], function (
	Class,
	Object,
	Presenter,
	Service,
	SystemIcon,
	Button,
	GridPanel,
	Heading,
	StackPanel,
	Text,
	TranslationKeys,
	ComponentWithHelp,
	Constants,
	UrlHelper
) {
	'use strict';

	var BasicInfoSourcesPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class BasicInfoSourcesPresenter
		 * @extends Presenter
		 */
		initialize: function BasicInfoSourcesPresenter(options) {
			BasicInfoSourcesPresenter.$super.call(this, options);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends BasicInfoSourcesPresenter# */
		properties: {},

		/** @lends BasicInfoSourcesPresenter# */
		methods: {

			_createField: function (
				title,
				text,
				url,
				textAutomationId,
				buttonAutomationId,
				fieldId
			) {

				var content = new StackPanel({
					justification: StackPanel.Justification.START,
					orientation: StackPanel.Orientation.HORIZONTAL,
					alignment: StackPanel.Alignment.CENTER
				});

				var textPart = new Text({
					text: text,
					automationId: textAutomationId
				});

				var linkPart = new Button({
					ariaLabel: this.i18n.get(title),
					visible: text !== PresenterConstants.EMPTY_VALUE,
					type: Button.Type.PURE,
					icon: SystemIcon.OPEN_NEW,
					automationId: buttonAutomationId,
					action: function (btnArgs) {
						window.open(url, '_blank');
					}
				});
				content.add(textPart);
				content.add({
					component: linkPart
				});

				return new ComponentWithHelp({
					component: content,
					label: this.i18n.get(title),
					helpService: this._helpService,
					fieldId: fieldId,
					labelPlacement: ComponentWithHelp.labelPlacement.TOP,
					type: ComponentWithHelp.TYPE.LABEL
				});
			},

			_removeInitialSlash: function (value) {
				return value[0] === "/" ?
					value.substring(1) :
					value;
			},

			_formatAppFolderPathValue: function () {
				return this._removeInitialSlash(this.state.manage.spa.spaFolder.path);
			},

			_createAppFolderField: function () {
				this._appFolderField = this._createField(
					TranslationKeys.SPA_MANAGE_FIELD_APP_FOLDER,
					this._formatAppFolderPathValue(),
					this._buildUrl(this.state.manage.spa.spaFolder.id),
					AutomationIds.SPA_FOLDER_FIELD,
					AutomationIds.SPA_FOLDER_BUTTON,
					Constants.FLH.FIELD.SPA_FOLDER);
			},

			_formatAssetsPathValue: function () {
				return this.state.manage.spa.assetsFolder.path === undefined
				|| this.state.manage.spa.assetsFolder.path === null || this.state.manage.spa.assetsFolder.path === '' ?
					PresenterConstants.EMPTY_VALUE :
					this._removeInitialSlash(this.state.manage.spa.assetsFolder.path);
			},

			_createAssetsFolderField: function () {

				this._assetsFolderField = this._createField(
					TranslationKeys.SPA_MANAGE_FIELD_ASSETS_FOLDER,
					this._formatAssetsPathValue(),
					this._buildUrl(this.state.manage.spa.assetsFolder.id),
					AutomationIds.ASSETS_FOLDER_FIELD,
					AutomationIds.ASSETS_FOLDER_BUTTON,
					Constants.FLH.FIELD.SPA_ASSETS);
			},

			_createClientScriptField: function () {
				this._clientScriptField = this._createField(
					TranslationKeys.SPA_MANAGE_FIELD_CLIENT_SCRIPT,
					this.state.manage.spa.clientScript.name,
					this._buildUrl(this.state.manage.spa.clientScript.parentFolderId),
					AutomationIds.CLIENT_SCRIPT_FIELD,
					AutomationIds.CLIENT_SCRIPT_BUTTON,
					Constants.FLH.FIELD.SPA_CLIENT_SCRIPT);
			},

			_createServerScriptField: function () {
				this._serverScriptField = this._createField(
					TranslationKeys.SPA_MANAGE_FIELD_SERVER_SCRIPT,
					this.state.manage.spa.serverScript.name,
					this._buildUrl(this.state.manage.spa.serverScript.parentFolderId),
					AutomationIds.SERVER_SCRIPT_FIELD,
					AutomationIds.SERVER_SCRIPT_BUTTON,
					Constants.FLH.FIELD.SPA_SERVER_SCRIPT);
			},

			_createFields: function () {
				this._createAppFolderField();
				this._createAssetsFolderField();
				this._createClientScriptField();
				this._createServerScriptField();
			},
			_createGridPanelItem: function (component, rowIndex, columnIndex) {
				return {
					component: component,
					options: {
						rowIndex: rowIndex,
						columnIndex: columnIndex
					}
				};
			},
			_createPanelItems: function () {
				return [
					this._createGridPanelItem(this._appFolderField, 0, 0),
					this._createGridPanelItem(this._assetsFolderField, 0, 1),
					this._createGridPanelItem(this._clientScriptField, 1, 0),
					this._createGridPanelItem(this._serverScriptField, 1, 1)
				];
			},
			_createFieldsPanel: function () {

				this._createFields();
				this._fieldsPanel = new GridPanel({
					rowGap: GridPanel.GapSize.LARGE,
					columnGap: GridPanel.GapSize.MEDIUM,
					rows: 2,
					columns: ['1fr', '1fr', '1fr'],
					items: this._createPanelItems()
				});
			},

			_refreshFieldsPanel: function () {
				this._fieldsPanel.clear();
				this._createFields();
				this._fieldsPanel.add(this._createPanelItems());
			},

			_createHeading: function () {
				this._heading = new Heading({
					content: 'Sources', // TODO: TBT.
					type: Heading.Type.PAGE_SUBTITLE
				})
			},

			_createPlaceHolder: function () {

				this._createHeading();
				this._createFieldsPanel();

				this._placeholder = new GridPanel(
					{
						rowGap: GridPanel.GapSize.LARGE,
						outerGap: GridPanel.GapSize.MEDIUM,
						rows: 2,
						columns: 1,
						items: [
							this._heading,
							this._fieldsPanel
						]
					});
			},

			_buildUrl: function (folderId) {
				return UrlHelper.getFolderUrl(folderId);
			},

			_areSourceItemsChanged: function (old, current) {
				return old.manage.spa.spaFolder.id !== current.manage.spa.spaFolder.id ||
					old.manage.spa.spaFolder.path !== current.manage.spa.spaFolder.path ||
					old.manage.spa.assetsFolder.id !== current.manage.spa.assetsFolder.id ||
					old.manage.spa.assetsFolder.path !== current.manage.spa.assetsFolder.path ||
					old.manage.spa.clientScript.name !== current.manage.spa.clientScript.name ||
					old.manage.spa.clientScript.parentFolderId !== current.manage.spa.clientScript.parentFolderId ||
					old.manage.spa.serverScript.name !== current.manage.spa.serverScript.name ||
					old.manage.spa.serverScript.parentFolderId !== current.manage.spa.serverScript.parentFolderId;
			}
		},

		/** @lends BasicInfoSourcesPresenter# */
		overrides: {

			_onCreateView: function () {
				this._createPlaceHolder();
				return this._placeholder;
			},
			_onStateChanged: function (old, current) {
				if (this._areSourceItemsChanged(old, current)) {
					this._refreshFieldsPanel();
				}
			}
		},

		static: {
			AutomationIds: Object.freeze({
				SPA_FOLDER_FIELD: "manage-spa-basic-info-spa-folder",
				SPA_FOLDER_BUTTON: "manage-spa-basic-info-spa-folder-button",
				ASSETS_FOLDER_FIELD: "manage-spa-basic-info-assets-folder",
				ASSETS_FOLDER_BUTTON: "manage-spa-basic-info-assets-folder-button",
				CLIENT_SCRIPT_FIELD: "manage-spa-basic-info-client-script",
				CLIENT_SCRIPT_BUTTON: "manage-spa-basic-info-client-script-button",
				SERVER_SCRIPT_FIELD: "manage-spa-basic-info-server-script",
				SERVER_SCRIPT_BUTTON: "manage-spa-basic-info-server-button",
			}),
			Constants: Object.freeze({
				EMPTY_VALUE: "-"
			})
		}
	});

	var PresenterConstants = BasicInfoSourcesPresenter.Constants;
	var AutomationIds = BasicInfoSourcesPresenter.AutomationIds;

	return BasicInfoSourcesPresenter;
});