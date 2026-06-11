define('n/platform/systemnotes2/presenter/SnPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Date',
	'n/ui/classes/Object',
	'n/ui/classes/Type',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/compounds/app/Presenter',
	'n/ui/compounds/component/Pagination',
	'n/ui/widgets/data/ArrayDataSource',
	'n/ui/widgets/data/TreeDataSource',
	'n/ui/widgets/toolkit/DataGrid',
	'n/ui/widgets/toolkit/DateRange',
	'n/ui/widgets/toolkit/DatePicker',
	'n/ui/widgets/toolkit/Dropdown',
	'n/ui/widgets/toolkit/FormattedText',
	'n/ui/widgets/toolkit/Label',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/Text',
	'n/ui/widgets/toolkit/TextBox',
	'n/ui/widgets/toolkit/ToolBar',
	'n/ui/widgets/tooltip/Tooltip',
	'n/platform/systemnotes2/service/SnService'
], function (
	Class,
	Date,
	Object,
	Type,
	ImmutableObject,
	Presenter,
	Pagination,
	ArrayDataSource,
	TreeDataSource,
	DataGrid,
	DateRange,
	DatePicker,
	Dropdown,
	FormattedText,
	Label,
	StackPanel,
	Text,
	TextBox,
	ToolBar,
	Tooltip,
	SnService
) {
	'use strict';

	var SnPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class SnPresenter
		 * @extends Presenter
		 */
		initialize: function SnPresenter(options) {
			SnPresenter.$super.call(this, options);

			var settings = Object.extend({}, defaultOptions, options);
			this.pageSize = 20;
			this.fetchSize = 1000;
			this._dataLoadsCount = 0;
			this._dataAllLoaded = false;
			this.context.state = settings.state;

			if (Type.Value.is(options.eid)) {
				this.eid = options.eid;
			}
			if (Type.Value.is(options.pdid)) {
				this.pdid = options.pdid;
			}
			this.key = {};
			if (Type.Value.is(options.nkey1)) {
				this.key.nkey1 = options.nkey1;
			}
			if (Type.Value.is(options.nkey2)) {
				this.key.nkey2 = options.nkey2;
			}
			if (Type.Value.is(options.nkey3)) {
				this.key.nkey3 = options.nkey3;
			}
			if (Type.Value.is(options.nkey4)) {
				this.key.nkey4 = options.nkey4;
			}
			if (Type.Value.is(options.skey1)) {
				this.key.skey1 = options.skey1;
			}
			if (Type.Value.is(options.skey2)) {
				this.key.skey2 = options.skey2;
			}
			if (Type.Value.is(options.skey3)) {
				this.key.skey3 = options.skey3;
			}
			if (Type.Value.is(options.bkey1)) {
				this.key.bkey1 = options.bkey1;
			}
			if (Type.Value.is(options.bkey2)) {
				this.key.bkey2 = options.bkey2;
			}
			if (Type.Value.is(options.dkey1)) {
				this.key.dkey1 = options.dkey1;
			}
			var that = this;
			this._loadData(this, Date.today().addDay(-30), Date.today());
		},

		/** @lends SnPresenter# */
		properties: {},

		/** @lends SnPresenter# */
		methods: {
			_initLoading: function () {
				this._dataLoadsCount = 0;
				this._dataAllLoaded = false;
				this._paginationPlus.visible = true;
			},

			_loadData: function (that, dateStart, dateEnd) {
				SnService.getRequests(that.eid, that.pdid, that.key, that._dataLoadsCount * that.fetchSize, dateStart, dateEnd).then(function (reply) {
					var requests = reply.response;
					that.context.state = ImmutableObject.set(that.context.state, ['requests'], requests);
				});
			},

			_renderCell: function (args) {
				var value = args.cell.value ? args.cell.value.toString() : '';
				if (args.cell.column.name === 'user' || args.cell.column.name === 'role' || args.cell.column.name === 'object' || args.cell.column.name === 'valueOld' || args.cell.column.name === 'valueNew') {
					var text = new FormattedText({
						text: value,
						formatter: FormattedText.Formatter.BOLD,
						options: {
							ignoreCase: true,
							highlights: this._search.text
						},
						classList: 'n-w-datagrid__cell__text',
						wrap: false,
						tooltip: new Tooltip({
							content: value
						})
					});
					return text;
				} else {
					var text = new Text({
						text: value,
						classList: 'n-w-datagrid__cell__text',
						wrap: false,
						tooltip: new Tooltip({
							content: value
						})
					});
					return text;
				}
			},

			_filterTree: function (that, dataRows, search, firstLevel) {
				var shouldBeVisible = false;
				var index = 0;
				while (index < dataRows.length) {
					var item = dataRows[index];
					var found = false;
					item.cells.forEach(function (column, columnIndex) {
						if (column.column.name === 'user' || column.column.name === 'role' || column.column.name === 'object' || column.column.name === 'valueOld' || column.column.name === 'valueNew') {
							if (search.length > 0 && column.value !== undefined && column.value.toString().toLowerCase().includes(search.toLowerCase())) {
								found = true;
							}
						}
					});
					item.expand();
					var childrenFound = false;
					if (item.childCount > 0) {
						childrenFound = that._filterTree(that, item.childRows, search, false);
					}
					if (search.length > 0 && (childrenFound || found)) {
						item.expand();
					} else {
						item.collapse();
					}
					if (found || childrenFound || search.length === 0) {
						shouldBeVisible = true;
					}
					if (firstLevel && !found && !childrenFound && search.length > 0) {
						that._grid.dataSource.remove({index: index});
					} else {
						index++;
					}
				};
				return shouldBeVisible;
			},

			_filterAll: function (that, search) {
				that._grid.setDataSource(new TreeDataSource({data: JSON.parse(JSON.stringify(that._data))}));
				that._filterTree(that, that._grid.dataRows, search, true);
				var rowCount = that._grid.dataRows.length;
				if (rowCount <= that.pageSize && !that._dataAllLoaded) {
					that._loadData(that, that._dateRange.rangeStart, that._dateRange.rangeEnd);
				}
				that._pagination.rowsCount = rowCount > 0 ? rowCount : 1; // pagination does not accept zero
			}
		},

		/** @lends SnPresenter# */
		overrides: {
			_onCreateView: function () {
				var that = this;

				this._search = new TextBox({
					placeholder: that.i18n.get('NLHeadingContext.SYSTEMNOTES_SEARCH_PLACEHOLDER'),
					on: {
						textChanged: function (arg) {
							that._filterAll(that, arg.currentText);
						}
					}
				});
				this._dateRangeDropDown = new Dropdown({
					dataSource: new ArrayDataSource([
						that.i18n.get('NLHeadingContext.SYSTEMNOTES_DATE_RANGE_TODAY'),
						that.i18n.get('NLHeadingContext.SYSTEMNOTES_DATE_RANGE_LAST_7_DAYS'),
						that.i18n.get('NLHeadingContext.SYSTEMNOTES_DATE_RANGE_LAST_30_DAYS'),
						that.i18n.get('NLHeadingContext.SYSTEMNOTES_DATE_RANGE_LAST_90_DAYS'),
						that.i18n.get('NLHeadingContext.SYSTEMNOTES_DATE_RANGE_LAST_YEAR'),
						that.i18n.get('NLHeadingContext.SYSTEMNOTES_DATE_RANGE_LAST_2_YEARS'),
						that.i18n.get('NLHeadingContext.SYSTEMNOTES_DATE_RANGE_ALL_TIME'),
						that.i18n.get('NLHeadingContext.SYSTEMNOTES_DATE_RANGE_CUSTOM')
					]),
					selectedIndex: 2,
					on: {
						selectedItemChanged: function (args) {
							if (args.currentIndex !== args.oldIndex && args.currentIndex !== 7) {
								var dateStart = Date.today();
								var dateEnd = Date.today();
								if (args.currentIndex >= 1 && args.currentIndex < 4) {
									var dates = [-7, -30, -90];
									dateStart = Date.today().addDay(dates[args.currentIndex - 1]);
								}
								else
								if (args.currentIndex >= 4 && args.currentIndex < 6) {
									var dates = [-1, -2];
									dateStart = Date.today().addYear(dates[args.currentIndex - 4]);
								}
								else
								if (args.currentIndex === 6) {
									dateStart = null;
								}
								that._dateRange.rangeStart = dateStart;
								that._dateRange.rangeEnd = dateEnd;
								that._pagination.selectedPageIndex = 0;
								that._initLoading();
								that._loadData(that, that._dateRange.rangeStart, that._dateRange.rangeEnd);
							}
						}
					}
				});
				this._dateRange = new DateRange({
					range: {
						startDate: Date.today().addDay(-30),
						endDate: Date.today(),
					},
					inputOptions: {
						placeholder: '-',
					},
					on: {
						rangeChanged: function (args) {
							if (args.reason === 'dateChanged') {
								that._pagination.selectedPageIndex = 0;
								that._dateRangeDropDown.selectedIndex = 7;
								that._initLoading();
								that._loadData(that, that._dateRange.rangeStart, that._dateRange.rangeEnd);
							}
						}
					}
				});
				this._pagination = new Pagination({
					pages: {
						rowsPerPage: this.pageSize,
						rowsCount: 0
					},
					navigation: {
						type: Pagination.NavigationType.PAGE,
						pageIndicator: {
							editable: true
						}
					},
					rowsCounter: Pagination.RowsCounter.COMPLETE,
					on: {
						[Pagination.Event.SELECTED_PAGE_CHANGED]: function (args) {
							that._grid.pageNumber = args.currentIndex;
							if ((args.currentIndex + 1) * that.pageSize >= that._pagination.rowsCount && !that._dataAllLoaded) {
								that._loadData(that, that._dateRange.rangeStart, that._dateRange.rangeEnd);
							}
						}
					}
				});

				this._paginationPlus = new Label('+');

				this._startToolbar = new ToolBar({
					items: [
						this._search,
						this._dateRangeDropDown,
						this._dateRange
					]
				});
				this._endToolbar = new ToolBar({
					items: [
						this._pagination,
						this._paginationPlus
					]
				});

				this._toolbar = new StackPanel({
					items: [
						{
							component: this._startToolbar,
							options: StackPanel.ItemOptions.FILL_SPACE
						},
						this._endToolbar
					]
				});

				this._data = this.context.state.requests;
				this._grid = new DataGrid({
					dataSource: new TreeDataSource({data: JSON.parse(JSON.stringify(this._data))}),
					autoSize: DataGrid.SizingStrategy.FULL,
					columnStretch: true,
					paging: true,
					pageSize: this.pageSize,
					editable: false,
					cellCursor: false,
					rowCursor: false,
					columns: [
						{name: 'date', label: this.i18n.get('NLFormlabelContext.DATE_TIME'), binding: 'timeStampFormated', type: DataGrid.ColumnType.TEMPLATED, stretchFactor: 1, content: this._renderCell.bind(this)},
						{name: 'user', label: this.i18n.get('NLFormlabelContext.USER'), binding: 'userName', type: DataGrid.ColumnType.TEMPLATED, stretchFactor: 1, content: this._renderCell.bind(this)},
						{name: 'role', label: this.i18n.get('NLFormlabelContext.ROLE'), binding: 'roleName', type: DataGrid.ColumnType.TEMPLATED, stretchFactor: 1, content: this._renderCell.bind(this)},
						{name: 'context', label: this.i18n.get('NLFormlabelContext.CONTEXT'), binding: 'context', type: DataGrid.ColumnType.TEXT_BOX, stretchFactor: 1},
						{name: 'action', label: this.i18n.get('NLFormlabelContext.ACTION'), binding: 'actionType', type: DataGrid.ColumnType.TEXT_BOX, stretchFactor: 1},
						{name: 'object', label: this.i18n.get('NLHeadingContext.SYSTEMNOTES_OBJECT_FIELD'), binding: 'objectPath', type: DataGrid.ColumnType.TREE, width: 300, content: this._renderCell.bind(this)},
						{name: 'valueOld', label: this.i18n.get('NLFormlabelContext.OLD_VALUE'), binding: 'oldValueFormated', type: DataGrid.ColumnType.TEMPLATED, stretchFactor: 1, content: this._renderCell.bind(this)},
						{name: 'valueNew', label: this.i18n.get('NLFormlabelContext.NEW_VALUE'), binding: 'newValueFormated', type: DataGrid.ColumnType.TEMPLATED, stretchFactor: 1, content: this._renderCell.bind(this)}
					]
				});

				var panel = StackPanel.vertical([this._toolbar, this._grid]);

				return panel;
			},
			_onStateChanged: function (oldState, currentState) {
				if (this._view) {
					if (oldState.requests !== currentState.requests) {
						if (this._dataLoadsCount === 0) {
							this._data = currentState.requests;
						} else {
							this._data = this._data.concat(currentState.requests);
						}
						if (!Type.Array.is(this._data)) {
							this._data = [];
						}
						this._grid.setDataSource(new TreeDataSource({data: JSON.parse(JSON.stringify(this._data))}));
						this._pagination.rowsCount = this._data.length > 0 ? this._data.length : 1;
						this._dataLoadsCount++;
						if (currentState.requests.length < this.fetchSize) {
							this._dataAllLoaded = true;
							this._paginationPlus.visible = false;
						}
						if (this._search.text.length > 0) {
							this._filterAll(this, this._search.text);
						}
					}
				}
			}
		}
	});

	var defaultOptions = Object.freeze({
		state: {
			requests: []
		}
	});

	return SnPresenter;
});