define('n/suitescript-ui/spa/MainPage', [
	'n/ui/classes/Class',
	'n/ui/classes/app/Store',
	'n/ui/compounds/app/Presenter',
	'n/ui/compounds/routing/Router',
	'n/ui/compounds/Shell',
	'n/ui/widgets/Page',
	'n/ui/widgets/style/Theme',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/MainPresenter',
	'n/suitescript-ui/spa/RouteList',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/reducer/MainReducer',
	'n/suitescript-ui/spa/service/HttpProxyService',
	'n/suitescript-ui/spa/service/LinksService',
	'n/suitescript-ui/spa/service/LogLevelsService',
	'n/suitescript-ui/spa/service/MessageDefinitionService',
	'n/suitescript-ui/spa/service/RolesService',
	'n/suitescript-ui/spa/service/SpaService',
	'n/suitescript-ui/spa/service/SuiteappService',
	'n/suitescript-ui/spa/service/UserGroupService',
	'n/suitescript-ui/spa/service/UserService',
], function (
	Class,
	Store,
	Presenter,
	Router,
	Shell,
	Page,
	Theme,
	StackPanel,
	MainPresenter,
	RouteList,
	ServiceList,
	MainReducer,
	HttpProxyService,
	LinksService,
	LogLevelsService,
	MessageDefinitionService,
	RolesService,
	SpaService,
	SuiteappService,
	UserGroupService,
	UserService
) {
	'use strict';

	var MainPage = Class.create({
		/**
		 * @class MainPage
		 * @extends Page
		 */
		extend: Page,
		/**
		 * @class MainPage
		 * @param {Object} options
		 */
		initialize: function MainPage(options) {
			MainPage.$super.call(this, options);
			this.supportedThemes = [Theme.Name.REFRESHED, Theme.Name.REDWOOD];
		},
		methods: {
			_createMainPresenter: function (context) {
				var container = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL
				});
				this.shell.content = container;

				var childContext = context.createChild();

				var view = Presenter.create(MainPresenter, {
					parentContext: childContext
				}).createView();

				container.clear().add(view);
			},

			_createPageContext: function () {
				var storeOptions = {
					state: MainReducer.initialState,
					reducer: MainReducer
				};

				var store = window.__UIF_STORE_DEBUGGER__ ?
					window.__UIF_STORE_DEBUGGER__.connect(Store, storeOptions) :
					new Store(storeOptions);

				var context = this.context.createChild({
					name: 'root',
					state: store.state,
					actionDispatch: function (action) {
						store.dispatch(action);
					}
				});

				store.on(Store.Event.STATE_CHANGED, function (args) {
					context.state = args.currentState;
				});

				context.state = store.state;

				return context;
			},

			_createPageRouter: function (context) {
				var router = new Router({
					context: context,
					routes: RouteList
				});

				// Register router to services
				context.services.add(ServiceList.ROUTER, router);

				// Start the router service
				router.listen();
			},
			_createServices: function (context) {
				// Register other services
				context.services.add(ServiceList.MESSAGE_DEFINITION, new MessageDefinitionService({context: context}));
				context.services.add(ServiceList.HTTP_PROXY_SERVICE, new HttpProxyService({context: context}));
				context.services.add(ServiceList.SPA, new SpaService({context: context}));
				context.services.add(ServiceList.LINKS, new LinksService({context: context}));
				context.services.add(ServiceList.LOG_LEVELS, new LogLevelsService({context: context}));
				context.services.add(ServiceList.ROLES, new RolesService({context: context}));
				context.services.add(ServiceList.SUITEAPP, new SuiteappService({context: context}));
				context.services.add(ServiceList.USER_GROUPS, new UserGroupService({context: context}));
				context.services.add(ServiceList.USER, new UserService({context: context}));
			}
		},
		overrides: {
			run: function () {
				var context = this._createPageContext();
				this.shell.layout = Shell.LayoutType.APPLICATION;
				this._createPageRouter(context);
				this._createServices(context)
				this._createMainPresenter(context);
			}
		}
	});

	return MainPage;
});
