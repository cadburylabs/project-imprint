define('n/suitescript-ui/spa/list/presenter/ListMainPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/Heading',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/PageList',
	'n/suitescript-ui/spa/RouteList',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/list/TranslationKeys',
	'n/suitescript-ui/spa/list/presenter/SpaGridPresenter',
	'n/suitescript-ui/spa/list/reducer/SpaGridReducer',
	'n/suitescript-ui/spa/manage/common/UrlHelper'
], function (
	Class,
	Object,
	Presenter,
	Heading,
	StackPanel,
	PageList,
	RouteList,
	ServiceList,
	TranslationKeys,
	SpaGridPresenter,
	SpaGridReducer,
	UrlHelper
) {
	'use strict';

	var ListMainPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ListMainPresenter
		 * @extends Presenter
		 */
		initialize: function ListMainPresenter(options) {
			ListMainPresenter.$super.call(this, options);
			this._spaService = this.context.services.get(ServiceList.SPA);
		},

		/** @lends ListMainPresenter# */
		properties: {},

		/** @lends ListMainPresenter# */
		methods: {
			_createHeader: function () {
				return new Heading({
					type: Heading.Type.PAGE_TITLE,
					content: this.i18n.get(TranslationKeys.SPA_LIST_HEADER),
					automationId: AutomationIds.HEADER_ID
				});
			},
			_createGrid: function () {
				return this._createChild(SpaGridPresenter).createView();
			},
			loadSpaListData: function () {
				this._spaService.getSpaList()
					.then(this._spaListLoaded.bind(this))
					.catch(this._errorLoadingSpaList.bind(this));
			},
			_spaListLoaded: function (spaListResponse) {
				this._adaptEndpoindDataForGridContent(spaListResponse.response);
				this.context.dispatchAction(SpaGridReducer.Action.SET_SPA_LIST, spaListResponse.response);

			},
			_adaptEndpoindDataForGridContent: function (spaList) {
				return spaList.forEach(function (element) {
					element.nameComposition = {
						name: element.name,
						manageUrl: Constants.pageUrl + RouteList.MANAGE.constructUrl({id: element.id}),
						spaUrl: UrlHelper.getSpaUrl(element.url, element.suiteAppId),
						locked: element.locked
					};
					return element;
				})
			},
			_errorLoadingSpaList: function () {
				this.context.dispatchAction(SpaGridReducer.Action.SET_SPA_LIST, []);
			}
		},

		/** @lends ListMainPresenter# */
		overrides: {
			_onCreateView: function () {
				document.title = this.i18n.get(TranslationKeys.SPA_LIST_HEADER);
				var container = new StackPanel({
					outerGap: StackPanel.GapSize.LARGE,
					orientation: StackPanel.Orientation.VERTICAL
				});
				container.add(this._createHeader());
				container.add(this._createGrid());
				this.loadSpaListData();

				return container;
			},
			_onStateChanged: function (old, current) {
				if ((old.router.page !== current.router.page)
					&& (current.router.page == PageList.LIST)) {
					this.loadSpaListData();
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				HEADER_ID: "list-spa-header"
			}),
			Constants: Object.freeze({
				pageUrl: window.location.origin + window.location.pathname,
				spaUrl: window.location.origin + '/spa/'
			})
		}
	});

	var AutomationIds = ListMainPresenter.AutomationIds;
	var Constants = ListMainPresenter.Constants;

	return ListMainPresenter;
});