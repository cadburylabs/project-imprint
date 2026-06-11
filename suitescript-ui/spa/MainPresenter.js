define('n/suitescript-ui/spa/MainPresenter', [
	'n/ui/classes/Class',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/PageList',
	'n/suitescript-ui/spa/list/presenter/ListMainPresenter',
	'n/suitescript-ui/spa/manage/presenter/ManageMainPresenter'
], function (
	Class,
	Presenter,
	StackPanel,
	PageList,
	ListMainPresenter,
	ManageMainPresenter
) {
	'use strict';

	var CssClass = {
		SETUP_APPLICATION: 'n-ssui-spa-manage-layout'
	};

	var MainPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class MainPresenter
		 * @extends Presenter
		 */
		initialize: function MainPresenter(options) {
			MainPresenter.$super.call(this, options);
		},

		/** @lends MainPresenter# */
		properties: {},

		/** @lends MainPresenter# */
		methods: {
			_updateView: function (pageName) {
				var presenterView = this._presenterPageMap[pageName];

				if (!presenterView) {
					presenterView = this._presenterPageMap[PageList.LIST];
				}

				this._content.clear().add({
					component: presenterView,
					options: StackPanel.ItemOptions.FILL_SPACE
				});
			},

			_createPresenterView: function (presenterClass) {
				return this._createChild(presenterClass).createView();
			},

			_initializePagePresenters: function () {
				this._presenterPageMap = [];
				this._presenterPageMap[PageList.MANAGE] = this._createPresenterView(ManageMainPresenter);
				this._presenterPageMap[PageList.LIST] = this._createPresenterView(ListMainPresenter);
			}
		},

		/** @lends MainPresenter# */
		overrides: {
			_onCreateView: function () {
				this._initializePagePresenters();
				this._content = new StackPanel({
					classList: [CssClass.SETUP_APPLICATION],
					orientation: StackPanel.Orientation.VERTICAL
				});
				this._updateView(this.state.router.page);
				return this._content;
			},

			_onStateChanged: function (old, current) {
				if (old.router.page !== current.router.page) {
					this._updateView(current.router.page);
				}
			}
		}
	});

	return MainPresenter;
});