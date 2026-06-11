define('n/suitescript-ui/spa/list/presenter/SpaGridPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/data/ArrayDataSource',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Button',
	'n/ui/widgets/toolkit/DataGrid',
	'n/ui/widgets/toolkit/Link',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/list/TranslationKeys',
	'n/ui/widgets/toolkit/Image'
], function (
	Class,
	Object,
	Presenter,
	ArrayDataSource,
	SystemIcon,
	Button,
	DataGrid,
	Link,
	StackPanel,
	TranslationKeys,
	Image
) {
	'use strict';

	var SpaGridPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class SpaGridPresenter
		 * @extends Presenter
		 */
		initialize: function SpaGridPresenter(options) {
			SpaGridPresenter.$super.call(this, options);
		},

		/** @lends SpaGridPresenter# */
		properties: {},

		/** @lends SpaGridPresenter# */
		methods: {
			_createNameColumnContent: function (args) {
				var content = new StackPanel({
					outerGap: StackPanel.GapSize.MEDIUM,
					justification: StackPanel.Justification.SPACE_BETWEEN,
					orientation: StackPanel.Orientation.HORIZONTAL,
					alignment: StackPanel.Alignment.CENTER,
					classList: [CssClass.CELL_STATUS]
				});
				var linkPart = new Link({
					content: args.cell.value.name,
					url: args.cell.value.manageUrl,
					wrap: false
				});
				var buttonPart = new Button({
					ariaLabel: args.cell.value.spaUrl,
					type: Button.Type.PURE,
					icon: SystemIcon.OPEN_NEW,
					automationId: AutomationIds.APP_URL_PREFIX + args.cell.value.spaUrl,
					action: function (btnArgs) {
						window.open(args.cell.value.spaUrl, '_blank');
					}
				});

				if (args.cell.value.locked) {
					content.add({
						component: new Image({
							image: SystemIcon.LOCK,
							presentation: true
						})
					});
				}

				content.add({
					component: linkPart,
					options: StackPanel.ItemOptions.FILL_SPACE
				});

				content.add({
					component: buttonPart,
					options: StackPanel.ItemOptions.KEEP_SIZE
				});
				return content;
			}
		},

		/** @lends SpaGridPresenter# */
		overrides: {
			_onCreateView: function () {
				var that = this;
				this._component = new DataGrid({
					automationId: 'item-grid',
					dataSource: new ArrayDataSource(that.state.list.spaList),
					columnStretch: true,
					resizableColumns: false,
					editable: false,
					rowCursor: false,
					cellCursor: false,
					columns: [
						{
							name: 'name',
							label: this.i18n.get(TranslationKeys.SPA_LIST_COLUMN_NAME),
							binding: 'nameComposition',
							type: DataGrid.ColumnType.TEMPLATED,
							content: that._createNameColumnContent.bind(this),
							stretchFactor: 29
						},
						{
							name: 'description',
							label: this.i18n.get(TranslationKeys.SPA_LIST_COLUMN_DESC),
							binding: 'description',
							type: DataGrid.ColumnType.TEXT_BOX,
							stretchFactor: 22
						},
						{
							name: 'suiteApp',
							label: this.i18n.get(TranslationKeys.SPA_LIST_COLUMN_SUITEAPP),
							binding: 'suiteAppName',
							type: DataGrid.ColumnType.TEXT_BOX,
							stretchFactor: 13
						},
						{
							name: 'spaId',
							label: this.i18n.get(TranslationKeys.SPA_LIST_COLUMN_SPA_ID),
							binding: 'id',
							type: DataGrid.ColumnType.TEXT_BOX,
							stretchFactor: 13
						},
						{
							name: 'lastUpdated',
							label: this.i18n.get(TranslationKeys.SPA_LIST_COLUMN_UPDATED),
							binding: 'lastUpdated',
							type: DataGrid.ColumnType.TEXT_BOX,
							stretchFactor: 13
						}
					]
				});

				return this._component;
			},
			_onStateChanged: function (old, current) {
				if (old.list.spaList !== current.list.spaList) {
					this._component.dataSource = new ArrayDataSource(this.state.list.spaList);
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				APP_URL_PREFIX: "list-spa-app-button-"
			}),
			CssClass: Object.freeze({
				CELL_STATUS: 'n-ssui-spa-list-grid-cell-status'
			})
		}
	});

	var AutomationIds = SpaGridPresenter.AutomationIds;
	var CssClass = SpaGridPresenter.CssClass;

	return SpaGridPresenter;
});