define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/ConfigurationCenterLinksPresenter', [
	'n/ui/classes/Class',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/Heading',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/layout/GapSize',
	'n/suitescript-ui/spa/manage/common/PermissionHelper',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/CenterLinkListPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/CenterLinksAddButtonPresenter'
], function (
	Class,
	Presenter,
	Heading,
	StackPanel,
	GapSize,
	PermissionHelper,
	CenterLinkListPresenter,
	CenterLinksAddButtonPresenter
) {
	'use strict';

	var ConfigurationCenterLinksPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ConfigurationCenterLinksPresenter
		 * @extends Presenter
		 */
		initialize: function ConfigurationCenterLinksPresenter(options) {
			this.constructor.$super.call(this, options);
		},

		/** @lends ConfigurationCenterLinksPresenter# */
		properties: {},

		/** @lends ConfigurationCenterLinksPresenter# */
		methods: {
			_createPresenterView: function (presenterClass) {
				return this._createChild(presenterClass).createView();
			},
			_createHeader: function () {
				return new Heading({
					content: "Center Links",
					type: Heading.Type.PAGE_SUBTITLE
				})
			}
		},

		/** @lends ConfigurationCenterLinksPresenter# */
		overrides: {
			_onCreateView: function () {
				this._placeholder = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL,
					itemGap: GapSize.MEDIUM,
					outerGap: GapSize.MEDIUM,
					alignment: StackPanel.Alignment.START
				});
				this._placeholder.add(this._createHeader());
				this._placeholder.add(this._createPresenterView(CenterLinkListPresenter));

				if (PermissionHelper.userHasEditPermission()) {
					this._placeholder.add(this._createPresenterView(CenterLinksAddButtonPresenter));
				}

				return this._placeholder;
			}
		}
	});

	return ConfigurationCenterLinksPresenter;
});