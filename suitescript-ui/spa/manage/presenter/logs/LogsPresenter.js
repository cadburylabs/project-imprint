define('n/suitescript-ui/spa/manage/presenter/logs/LogsPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/compounds/component/Pagination',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Button',
	'n/ui/widgets/toolkit/Image',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/Text',
	'n/ui/widgets/toolkit/layout/GapSize',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/Navigation',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/presenter/logs/Constants',
	'n/suitescript-ui/spa/manage/presenter/logs/LogsDataGridPresenter',
	'n/suitescript-ui/spa/manage/reducer/LogsReducer',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function (
	Class,
	Object,
	Presenter,
	Pagination,
	SystemIcon,
	Button,
	Image,
	StackPanel,
	Text,
	GapSize,
	ServiceList,
	Navigation,
	TranslationKeys,
	Constants,
	LogsDataGridPresenter,
	LogsReducer,
	StateProps
) {
	'use strict';

	var LogsPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class LogsPresenter
		 * @extends Presenter
		 */
		initialize: function LogsPresenter(options) {
			LogsPresenter.$super.call(this, options);
			this._spaService = this.context.services.get(ServiceList.SPA);
		},

		/** @lends LogsPresenter# */
		properties: {},

		/** @lends LogsPresenter# */
		methods: {
			_createLogPanel: function () {
				this._logPanel = new StackPanel({
					outerGap: StackPanel.GapSize.LARGE,
					orientation: StackPanel.Orientation.VERTICAL,
				});
				return this._logPanel;
			},
			_errorNoticationSection: function () {

				this._message = new Text({
					text: this.i18n.get(TranslationKeys.SPA_MANAGE_LOGS_ERROR),
					automationId: AutomationIds.ERROR_TEXT
				});
				this._icon = new Image({
					image: SystemIcon.ALERT.withCaption(this.i18n.get(TranslationKeys.SPA_MANAGE_LOGS_ERROR)),
					automationId: AutomationIds.ICON,
					classList: [CssClass.ERROR_COMPONENT],
				});
				this._errorNotification = new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					items: [this._icon, this._message],
					alignment: StackPanel.Alignment.CENTER,
					itemGap: GapSize.SMALL
				});
				this._errorNotification.visible = false;
				return this._errorNotification;
			},
			_logsDataGridPresenter: function () {
				this._logsDatatGrid = Presenter.create(LogsDataGridPresenter, {
					parentContext: this.context.createChild()
				}).createView();
				return this._logsDatatGrid;
			},
			_loadSpaLogs: function (spaId, pageNumber) {
				if (spaId) {
					this._spaService.getSpaLogs(spaId, Constants.PAGE_SIZE, pageNumber)
						.then(this._logsLoadedSuccessfully.bind(this, pageNumber))
						.catch(this._errorLoadingLogs.bind(this, pageNumber));
				}
			},
			_logsLoadedSuccessfully: function (pageNumber, logs) {
				this.context.dispatchAction(LogsReducer.Action.LOGS_RETRIEVED, logs.response);
				this._displayLogGrid(pageNumber);
			},
			_errorLoadingLogs: function (pageNumber) {
				this._displayLogGrid(pageNumber);
				this.context.dispatchAction(LogsReducer.Action.ERROR);
			},
			_refreshButtonAction: function (pageNumber){
				this._loadSpaLogs(this.state.manage.spa.id, pageNumber);
			},
			_refreshButton: function (pageNumber) {
				return new Button({
					automationId: AutomationIds.REFRESH_BUTTON,
					label: this.i18n.get(TranslationKeys.SPA_MANAGE_LOGS_REFRESH_BUTTON),
					type: Button.Type.GHOST,
					action: this._refreshButtonAction.bind(this, pageNumber)
				})
			},
			_actionButtonsSection: function (pageNumber) {
				return new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					justification: StackPanel.Justification.SPACE_BETWEEN,
					items: [this._refreshButton(pageNumber), this._paginator(pageNumber)]
				})
			},
			_displayLogGrid: function (pageNumber) {
				this._logPanel.clear();
				this._logPanel.add(this._errorNoticationSection());
				this._logPanel.add({
					component: this._actionButtonsSection(pageNumber),
					options: {
						shrink: 0
					}});
				this._logPanel.add(this._logsDataGridPresenter());
				if (this.state.manage.logs.status === StateProps.LOGS.STATUS.ERROR) {
					this._displayErrorNotification(true);
				}
			},
			_paginator: function (currentPage) {
				var rowCount = this.state.manage.logs.logCount;
				this._paginatorPanel = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL
				});
				this._pagination = new Pagination({
					selectedPageIndex: currentPage,
					pages: {
						rowsCount: rowCount,
						rowsPerPage: Constants.PAGE_SIZE
					},
					on: {
						[Pagination.Event.SELECTED_PAGE_CHANGED]: this._onPageChanged.bind(this)
					}
				});
				this._paginatorPanel.add({component: this._pagination, selfAlignment: StackPanel.SelfAlignment.END});
				return this._paginatorPanel;
			},
			_onPageChanged: function (args) {
				var requestedPageNumber = args.currentIndex;
				this.dispatchAction(LogsReducer.Action.LOADING)
				this._loadSpaLogs(this.state.manage.spa.id, requestedPageNumber)
			},
			_displayErrorNotification: function (visible) {
				this._errorNotification.visible = visible;
			},
			_stateChanged: function (currentState) {
				if (this._stateChangedFunction[currentState] !== undefined) {
					this._stateChangedFunction[currentState]();
				}
			},
			_setupStateChangedFunctions: function () {
				this._stateChangedFunction = [];
				this._stateChangedFunction[StateProps.LOGS.STATUS.IDLE] = this._displayErrorNotification.bind(this, false);
				this._stateChangedFunction[StateProps.LOGS.STATUS.ERROR] = this._displayErrorNotification.bind(this, true);
			}
		},

		/** @lends LogsPresenter# */
		overrides: {
			_onCreateView: function () {
				this._setupStateChangedFunctions();
				return this._createLogPanel();

			},
			_onStateChanged: function (old, current) {
				if ((old.manage.spa.id !== current.manage.spa.id) ||
					//logs loaded everytime logs menu item is clicked
					(old.router.tab !== current.router.tab) && (current.router.tab === Navigation.LOGS)) {
					this._loadSpaLogs(current.manage.spa.id, 0);
				}
				if (old.manage.logs.status !== current.manage.logs.status) {
					this._stateChanged(current.manage.logs.status);
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				CONTENT_ID: "manage-spa-logs-content",
				ERROR_TEXT: "manage-spa-logs-error-text",
				REFRESH_BUTTON: "manage-spa-logs-refresh-button"

			}),
			CssClass: Object.freeze({
				ERROR_COMPONENT: 'n-ssui-spa-manage-error-component',
			})
		}
	});

	var AutomationIds = LogsPresenter.AutomationIds;
	var CssClass = LogsPresenter.CssClass;

	return LogsPresenter;
});