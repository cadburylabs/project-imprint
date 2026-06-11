define('n/suitescript-ui/spa/manage/presenter/ManageMainPresenter', [
	'n/ui/classes/Class',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/Service',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/RouteList',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/Navigation',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/CreationBannerPresenter',
	'n/suitescript-ui/spa/manage/common/SpinnerComponent',
	'n/suitescript-ui/spa/manage/presenter/HeaderPresenter',
	'n/suitescript-ui/spa/manage/presenter/MenuPresenter',
	'n/suitescript-ui/spa/manage/presenter/auditTrail/AuditTrailPresenter',
	'n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/ConfigurationPresenter',
	'n/suitescript-ui/spa/manage/presenter/logs/LogsPresenter',
	'n/suitescript-ui/spa/manage/reducer/ManageMainReducer',
	'n/suitescript-ui/spa/manage/reducer/Notification',
	'n/suitescript-ui/spa/service/HttpProxyService'
], function (
	Class,
	Presenter,
	Service,
	StackPanel,
	RouteList,
	ServiceList,
	Navigation,
	TranslationKeys,
	CreationBannerPresenter,
	SpinnerComponent,
	HeaderPresenter,
	MenuPresenter,
	AuditTrailPresenter,
	BasicInfoPresenter,
	ConfigurationPresenter,
	LogsPresenter,
	ManageMainReducer,
	Notification,
	HttpProxyService
) {
	'use strict';

	var ManageMainPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ManageMainPresenter
		 * @extends Presenter
		 */
		initialize: function ManageMainPresenter(options) {
			ManageMainPresenter.$super.call(this, options);
			this._spaService = this.context.services.get(ServiceList.SPA);
			this._messagingService = this.context.services.get(Service.MESSAGING);
			this._messageDefinitionService = this.context.services.get(ServiceList.MESSAGE_DEFINITION);
			this._routerService = this.context.services.get(ServiceList.ROUTER);
		},

		/** @lends ManageMainPresenter# */
		properties: {},

		/** @lends ManageMainPresenter# */
		methods: {
			_updateView: function (navigation) {
				var presenterView = this._presenterNavigationMap[navigation];

				if (!presenterView) {
					//safety-check to ensure we don't add new navigations and forget about registering the presenters
					throw "Error: Presenter class not found for navigation " + navigation;
				}

				this._content.clear();
				this._content.add(presenterView);
			},

			_createPresenterView: function (presenterClass) {
				return this._createChild(presenterClass).createView();
			},

			_initializePresenterNavigationMap: function () {
				this._presenterNavigationMap = [];
				this._presenterNavigationMap[Navigation.BASIC_INFO] = this._createPresenterView(BasicInfoPresenter);
				this._presenterNavigationMap[Navigation.AUDIT_TRAIL] = this._createPresenterView(AuditTrailPresenter);
				this._presenterNavigationMap[Navigation.LOGS] = this._createPresenterView(LogsPresenter);
				this._presenterNavigationMap[Navigation.CONFIGURATION] = this._createPresenterView(ConfigurationPresenter);
			},

			_createMenu: function () {
				this._initializePresenterNavigationMap();
				return this._createPresenterView(MenuPresenter);
			},

			_createHeader: function () {
				this._header = this._createChild(HeaderPresenter).createView();
				return this._header;
			},

			_createContentPage: function () {
				this._content = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL,
					justification: StackPanel.Justification.SPACE_BETWEEN
				});

				return this._content;
			},
			_showSpinner: function () {
				this._header.visible = false;
				this._content.visible = false;
				this._loader.visible = true;
			},
			_hideSpinner: function () {
				this._loader.visible = false;
				this._header.visible = true;
				this._content.visible = true;
			},
			_dispatchSpaCreatedBanner: function () {
				var bannerPresenter = this._createChild(CreationBannerPresenter);
				var notification = new Notification({
					type: Notification.TYPE.SUCCESS,
					definition: this._messageDefinitionService.spaCreatedBanner(bannerPresenter.createView())
				});
				this.dispatchAction(ManageMainReducer.Action.SET_NOTIFICATION, notification);
			},
			_spaDetailsLoaded: function (httpResponse) {
				this.context.dispatchAction(ManageMainReducer.Action.Set_SPA, httpResponse.response);
				//Check whether to display banner
				var displayBanner = this._routerService._activeParams.displaybanner;
				if (displayBanner !== undefined && displayBanner === 'true') {
					this._dispatchSpaCreatedBanner()
				}
				this._hideSpinner();
			},
			_loadSpaDetails: function (id) {
				if (id !== "" && id !== this.state.manage.spa.id) {
					this._showSpinner();
					this._spaService.getSpaDetails(id).then(this._spaDetailsLoaded.bind(this));
				}
			},
			_createLoader: function () {
				this._loader = SpinnerComponent.new({
					style:{
						width: 'auto',
						height: '120px',
						padding: '2px'
					}
				});
				return this._loader;
			},
			_createContentLayout: function () {
				var layoutContent = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL,
					outerGap: StackPanel.GapSize.MEDIUM,
					alignment: StackPanel.Alignment.STRETCH
				});
				layoutContent.add({component: this._createHeader(), options: StackPanel.ItemOptions.KEEP_SIZE});

				var layoutSection = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL});
				layoutSection.add(this._createLoader());
				layoutSection.add(this._createContentPage());
				layoutContent.add(layoutSection);

				return layoutContent;
			},
			_fireNotification: function (notification) {
				if (notification.isSuccessType()) {
					this._messagingService.success(notification.definition);
				}
				else {
					this._messagingService.error(notification.definition);
				}
			},
			_dispatchMessage: function (type, messageDefinition) {
				var notification = new Notification({
					type: type,
					definition: messageDefinition
				});
				this._context.dispatchAction(ManageMainReducer.Action.SET_NOTIFICATION, notification);
			},
			_spaStatusChanged: function (newStatus) {
				if (newStatus === HttpProxyService.HTTP_STATUS.NOT_FOUND) {
					this._routerService.routeTo(RouteList.LIST);
					this._dispatchMessage(Notification.TYPE.ERROR, this._messageDefinitionService.spaDoesNotExist());
				}
			}
		},

		/** @lends ManageMainPresenter# */
		overrides: {
			_onCreateView: function () {
				document.title = this.i18n.get(TranslationKeys.SPA_MANAGE_TITLE);

				var layout = new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					alignment: StackPanel.Alignment.STRETCH
				});

				layout.add({
					options: {
						flex: 1,
						shrink: 0
					},
					component: this._createMenu()
				});

				layout.add({
					options: StackPanel.ItemOptions.FILL_SPACE,
					component: this._createContentLayout()
				});

				this._loadSpaDetails(this.state.router.id);

				this._updateView(this.state.router.tab);

				return layout;
			},

			_onStateChanged: function (old, current) {
				if (old.router.tab !== current.router.tab) {
					this._updateView(current.router.tab);
				}
				if (old.router.id !== current.router.id) {
					this._loadSpaDetails(current.router.id);
				}
				if (old.manage.notification !== current.manage.notification) {
					this._fireNotification(current.manage.notification);
				}
				if (old.manage.requests.spaDetails.status !== current.manage.requests.spaDetails.status) {
					this._spaStatusChanged(current.manage.requests.spaDetails.status);
				}
			}
		}
	});

	return ManageMainPresenter;
});