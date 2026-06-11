define('n/suitescript-ui/spa/manage/presenter/logs/LogsDataGridPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/data/ArrayDataSource',
	'n/ui/widgets/helper/Loader',
	'n/ui/widgets/scrolling/ScrollPanel',
	'n/ui/widgets/toolkit/DataGrid',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/Text',
	'n/ui/widgets/toolkit/datagrid/GridCell',
	'n/ui/widgets/toolkit/datagrid/GridRow',
	'n/ui/widgets/toolkit/layout/GapSize',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/presenter/logs/Constants',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function (
	Class,
	Object,
	Presenter,
	ArrayDataSource,
	Loader,
	ScrollPanel,
	DataGrid,
	StackPanel,
	Text,
	GridCell,
	GridRow,
	GapSize,
	TranslationKeys,
	Constants,
	StateProps
) {
	'use strict';

	var LogsDataGridPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class LogsDataGridPresenter
		 * @extends Presenter
		 */
		initialize: function LogsDataGridPresenter(options) {
			LogsDataGridPresenter.$super.call(this, options);
		},

		/** @lends LogsPresenter# */
		properties: {},

		/** @lends LogsPresenter# */
		methods: {
			_createLogsGrid: function () {
				this._logsGrid = new DataGrid({
					automationId: AutomationIds.CONTENT_ID,
					columnStretch: true,
					resizableColumns: false,
					editable: false,
					rowCursor: false,
					cellCursor: false,
					dataSource: new ArrayDataSource(this.state.manage.logs.logList),
					dataLoader: {
						icon: Loader.Icon.CIRCULAR,
						verticalAlignment: Loader.VerticalAlignment.MIDDLE,
						horizontalAlignment: Loader.VerticalAlignment.STRETCH
					},
					placeholder: this.i18n.get(TranslationKeys.SPA_MANAGE_LOGS_NO_LOGS),
					paging: true,
					pageSize: Constants.PAGE_SIZE,
					customizeRow: this._renderCustomizeRow.bind(this),
					columns: [
						{
							name: 'date',
							label: this.i18n.get(TranslationKeys.SPA_MANAGE_LOGS_GRID_COLUMN_DATE),
							binding: 'timeStamp',
							type: DataGrid.ColumnType.TEXT_BOX,
							stretchFactor: 14
						},
						{
							name: 'user',
							label: this.i18n.get(TranslationKeys.SPA_MANAGE_LOGS_GRID_COLUMN_USER),
							binding: 'userName',
							type: DataGrid.ColumnType.TEXT_BOX,
							stretchFactor: 14
						},
						{
							name: 'logLevel',
							label: this.i18n.get(TranslationKeys.SPA_MANAGE_LOGS_GRID_COLUMN_LOG_LEVEL),
							binding: 'logLevel',
							type: DataGrid.ColumnType.TEXT_BOX,
							stretchFactor: 9
						},
						{
							name: 'title',
							label: this.i18n.get(TranslationKeys.SPA_MANAGE_LOGS_GRID_COLUMN_TITLE),
							binding: 'title',
							type: DataGrid.ColumnType.TEXT_BOX,
							stretchFactor: 18
						},
						{
							name: 'details',
							label: this.i18n.get(TranslationKeys.SPA_MANAGE_LOGS_GRID_COLUMN_DETAILS),
							binding: 'details',
							type: DataGrid.ColumnType.DETAIL,
							stretchFactor: 45
						}
					]
				});

				return this._logsGrid;

			},
			_renderDetailRow: function (value, logId) {
				return new ScrollPanel({
					content: new StackPanel({
						orientation: StackPanel.Orientation.VERTICAL,
						outerGap: GapSize.MEDIUM,
						alignment: StackPanel.Alignment.STRETCH,
						items: [
							new Text({
								automationId: AutomationIds.DETAIL_ROW_ID + logId,
								text: value,
								whitespace: true
							})
						]
					})
				});
			},
			_renderCustomizeRow: function (dataGridContext) {
				var dataItem = dataGridContext.dataItem;
				if (dataItem.details !== "") {
					var row = dataGridContext.row;
					var detailrow = this._createCustomRow(dataGridContext);
					row.setDetailRow(detailrow);
				}
			},
			_createCustomRow: function (dataGridContext) {
				var dataGrid = dataGridContext.dataGrid;
				var dataItem = dataGridContext.dataItem;
				var that = this;
				return dataGrid.createSyntheticRow({
					height: GridRow.Height.AUTO,
					cellConfiguration: function (row, column) {
						if (column === dataGrid.bodyRootColumn) {
							return that._createCustomCell(row, column, dataGrid, dataItem)
						}
					}
				});
			},
			_createCustomCell: function (row, column, dataGrid, dataItem) {
				return dataGrid.createSyntheticCell({
					row: row,
					column: column,
					horizontalAlignment: GridCell.HorizontalAlignment.STRETCH,
					verticalAlignment: GridCell.VerticalAlignment.STRETCH,
					content: this._renderDetailRow(dataItem.details, dataItem.logId)
				})
			},
			_updateGridContent: function () {
				this._logsGrid.dataSource = new ArrayDataSource(this.state.manage.logs.logList);
				this._showLoader(false);
			},
			_showLoader: function (visible) {
				this._logsGrid.dataLoader.visible = visible;
			}
		},

		/** @lends LogsPresenter# */
		overrides: {
			_onCreateView: function () {
				return this._createLogsGrid();
			},
			_onStateChanged: function (old, current) {
				if (old.manage.logs.logList !== current.manage.logs.logList) {
					this._updateGridContent();
				}
				if (current.manage.logs.status === StateProps.LOGS.STATUS.LOADING) {
					this._showLoader(true);
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				CONTENT_ID: "manage-spa-logs-content",
				DETAIL_ROW_ID: "manage-spa-logs-content-detail-"
			})
		}
	});

	var AutomationIds = LogsDataGridPresenter.AutomationIds;

	return LogsDataGridPresenter;
});