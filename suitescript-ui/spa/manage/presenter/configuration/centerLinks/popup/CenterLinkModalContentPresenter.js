define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/CenterLinkModalContentPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/GridPanel',
	'n/ui/widgets/toolkit/layout/GapSize',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalInsertBeforeFieldPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalLinkLabelFieldPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalLocationFieldPresenter'
], function (
	Class,
	Object,
	Presenter,
	GridPanel,
	GapSize,
	CenterLinkModalInsertBeforeFieldPresenter,
	CenterLinkModalLinkLabelFieldPresenter,
	CenterLinkModalLocationFieldPresenter
) {
	'use strict';

	var LinkModalContentPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class LinkModalContentPresenter
		 * @extends Presenter
		 */
		initialize: function LinkModalContentPresenter(options) {
			LinkModalContentPresenter.$super.call(this, options);
		},

		/** @lends LinkModalContentPresenter# */
		properties: {},

		/** @lends LinkModalContentPresenter# */
		methods: {
			_createGridPanelItem: function (presenter, rowIndex, columnIndex, columnSpan) {
				return {
					component: this._createChild(presenter).createView(),
					options: {
						rowIndex: rowIndex,
						columnIndex: columnIndex,
						columnSpan: columnSpan
					}
				}
			},
			_createLocationField: function () {
				return this._createGridPanelItem(CenterLinkModalLocationFieldPresenter, 0, 0, 2);
			},
			_createLinkLabelField: function () {
				return this._createGridPanelItem(CenterLinkModalLinkLabelFieldPresenter, 1, 0, 2);
			},
			_createInsertBeforeField: function () {
				return this._createGridPanelItem(CenterLinkModalInsertBeforeFieldPresenter, 1, 2, 1);
			}
		},

		/** @lends LinkModalContentPresenter# */
		overrides: {
			_onCreateView: function () {
				return new GridPanel({
					rowGap: GapSize.MEDIUM,
					columnGap: GapSize.MEDIUM,
					outerGap: GapSize.MEDIUM,
					ariaLabel: AutomationIds.MODAL_ID,
					automationId: AutomationIds.MODAL_ID,
					columns: 3,
					items: [
						this._createLocationField(),
						this._createLinkLabelField(),
						this._createInsertBeforeField()
					]
				});
			}
		},
		static: {
			AutomationIds: Object.freeze({
				MODAL_ID: "manage-spa-configuration-center-link-modal"
			})
		}
	});

	var AutomationIds = LinkModalContentPresenter.AutomationIds;

	return LinkModalContentPresenter;
});