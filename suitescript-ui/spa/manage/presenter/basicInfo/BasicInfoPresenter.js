define('n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoPresenter', [
	'n/ui/classes/Class',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/GridPanel',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoDescriptionPresenter',
	'n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoIdPresenter',
	'n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoNamePresenter',
	'n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoOwnerPresenter',
	'n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoSourcesPresenter',
	'n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoSuiteAppFieldPresenter',
	'n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoSuiteAppIdFieldPresenter',
	'n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoSuiteAppPublisherIdFieldPresenter',
	'n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoUrlPresenter',
	'n/suitescript-ui/spa/manage/presenter/basicInfo/actionButtons/ActionButtonsPresenter'
], function (
	Class,
	Presenter,
	GridPanel,
	StackPanel,
	Constants,
	BasicInfoDescriptionPresenter,
	BasicInfoIdPresenter,
	BasicInfoNamePresenter,
	BasicInfoOwnerPresenter,
	BasicInfoSourcesPresenter,
	BasicInfoSuiteAppFieldPresenter,
	BasicInfoSuiteAppIdFieldPresenter,
	BasicInfoSuiteAppPublisherIdFieldPresenter,
	BasicInfoUrlPresenter,
	ActionButtonsPresenter
) {
	'use strict';

	var BasicInfoPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class BasicInfoPresenter
		 * @extends Presenter
		 */
		initialize: function BasicInfoPresenter(options) {
			BasicInfoPresenter.$super.call(this, options);
		},

		/** @lends BasicInfoPresenter# */
		properties: {},

		/** @lends BasicInfoPresenter# */
		methods: {
			_createPresenterView: function (presenterClass) {
				return this._createChild(presenterClass).createView();
			},
			_createNotPublishedGridPanel() {
				this._createGridPanel();
				this._gridPanel.add(this._createPresenterView(BasicInfoNamePresenter));
				this._gridPanel.add(this._createPresenterView(BasicInfoIdPresenter));
				this._gridPanel.add(this._createPresenterView(BasicInfoDescriptionPresenter));
				if (this.state.manage.spa.suiteAppId != null) {
					this._gridPanel.add(this._createGridPanelItem(BasicInfoSuiteAppFieldPresenter));
					this._gridPanel.add(this._createGridPanelItem(BasicInfoSuiteAppIdFieldPresenter));
					this._gridPanel.add(this._createGridPanelItem(BasicInfoSuiteAppPublisherIdFieldPresenter));
				}
				this._gridPanel.add(this._createPresenterView(BasicInfoOwnerPresenter));
				this._gridPanel.add(this._createPresenterView(BasicInfoUrlPresenter));
				return this._gridPanel;
			},
			_createPublishedGridPanel() {
				this._createGridPanel();
				this._gridPanel.add(this._createPresenterView(BasicInfoNamePresenter));
				this._gridPanel.add(this._createPresenterView(BasicInfoIdPresenter));
				this._gridPanel.add(this._createPresenterView(BasicInfoDescriptionPresenter));
				if (this.state.manage.spa.suiteAppId != null) {
					this._gridPanel.add(this._createGridPanelItem(BasicInfoSuiteAppFieldPresenter));
				}
				this._gridPanel.add(this._createPresenterView(BasicInfoUrlPresenter));
				return this._gridPanel;
			},
			_createGridPanelItem: function (presenter, rowIndex, columnIndex) {
				return {
					component: this._createPresenterView(presenter),
					options: {
						rowIndex: rowIndex,
						columnIndex: columnIndex
					}
				};
			},
			_createGridPanel: function () {
				return this._gridPanel = new GridPanel({
					rowGap: GridPanel.GapSize.LARGE,
					columnGap: GridPanel.GapSize.MEDIUM,
					outerGap: GridPanel.GapSize.MEDIUM,
					columns: ['1fr', '1fr', '1fr']
				});
			},
			_createNotPublishedContent: function () {
				this._placeholder.clear();
				this._placeholder.add(this._createPresenterView(ActionButtonsPresenter));
				this._placeholder.add(this._createNotPublishedGridPanel());
				this._placeholder.add(this._createPresenterView(BasicInfoSourcesPresenter));
			},
			_createPublishedContent: function () {
				this._placeholder.clear();
				this._placeholder.add(this._createPresenterView(ActionButtonsPresenter));
				this._placeholder.add(this._createPublishedGridPanel());
			},
			_createContent: function () {
				if (this.state.manage.spa.type === Constants.NOT_PUBLISHED) {
					this._createNotPublishedContent();
				} else {
					this._createPublishedContent();
				}
			}
		},

		/** @lends BasicInfoPresenter# */
		overrides: {
			_onCreateView: function () {
				this._placeholder = new StackPanel({orientation: StackPanel.Orientation.VERTICAL});
				this._createContent();

				return this._placeholder;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.spa.suiteAppId !== current.manage.spa.suiteAppId ||
					old.manage.spa.type !== current.manage.spa.type) {
					this._createContent();
				}
			},
		}
	});

	return BasicInfoPresenter;
});