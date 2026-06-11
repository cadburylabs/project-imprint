define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/CenterLinkListPresenter', [
	'n/ui/classes/Class',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/common/SpinnerComponent',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/CenterLinkListItemPresenter',
	'n/suitescript-ui/spa/manage/reducer/SpaReducer'
], function (
	Class,
	Presenter,
	StackPanel,
	ServiceList,
	SpinnerComponent,
	CenterLinkListItemPresenter,
	SpaReducer
) {
	'use strict';

	var CenterLinkListPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class CenterLinkListPresenter
		 * @extends Presenter
		 */
		initialize: function CenterLinkListPresenter(options) {
			CenterLinkListPresenter.$super.call(this, options);
			this._spaService = this.context.services.get(ServiceList.SPA);
			this._itemLinkPresenters = []
			},

		/** @lends CenterLinkListPresenter# */
		properties: {},

		/** @lends CenterLinkListPresenter# */
		methods: {
			_addLinkToList: function (link) {
				var itemLink = this._createItemLinkPresenter(link)
				this._itemLinkPresenters[link.linkId] = itemLink;
				this._content.add({
					component: itemLink.createView()
				});
			},
			_createItemLinkPresenter: function(link) {
				return this._createChild(CenterLinkListItemPresenter, {
					presenterOptions: {
						linkDetails: link
					}
				})
			},
			_updateCenterLinkList: function (linkList) {
				this._setSpinnerVisible(true);
				if (linkList !== undefined) {
					this._removeAllItemLinks();
					this._addItemLinksFromList(linkList);
				}
				this._setSpinnerVisible(false);
			},
			_removeAllItemLinks: function() {
				this._itemLinkPresenters.forEach(function (linkItemPresenter) {linkItemPresenter.dispose()});
				this._content.clear();
			},
			_addItemLinksFromList: function(linkList) {
				linkList.forEach(this._addLinkToList.bind(this));
			},
			_linkListLoaded: function (response) {
				var centerLinkList = response.response;
				this.context.dispatchAction(SpaReducer.Action.SET_CENTER_LINKS, centerLinkList);
			},
			_loadLinkList: function (spaId) {
				this._spaService.getCenterLinkList(spaId)
					.then(this._linkListLoaded.bind(this));
			},
			_setSpinnerVisible: function (value) {
				this._loader.visible = value;
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
			}
		},

		/** @lends CenterLinkListPresenter# */
		overrides: {
			_onCreateView: function () {
				this._content = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL,
					items: [this._createLoader()]
				});

				this._setSpinnerVisible(true);

				return this._content;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.spa.centerLinks !== current.manage.spa.centerLinks){
					this._updateCenterLinkList(current.manage.spa.centerLinks);
				}

				if (old.manage.spa.id !== current.manage.spa.id
						&& current.manage.spa.id !== ""){
					this._loadLinkList(current.manage.spa.id);
				}
			}
		}
	});

	return CenterLinkListPresenter;
});