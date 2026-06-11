define('n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/ConfigurationErrorNotificationsPresenter', [
	'n/ui/classes/Class',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/Heading',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/layout/GapSize',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/PermissionHelper',
	'n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/ListPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/SetupNotificationsButtonPresenter'
], function (
	Class,
	Presenter,
	Heading,
	StackPanel,
	GapSize,
	TranslationKeys,
	PermissionHelper,
	ListPresenter,
	SetupNotificationsButtonPresenter
) {
	'use strict';

	var ConfigurationErrorNotificationsPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ConfigurationErrorNotificationsPresenter
		 * @extends Presenter
		 */
		initialize: function ConfigurationErrorNotificationsPresenter(options) {
			this.constructor.$super.call(this, options);
		},

		/** @lends ConfigurationErrorNotificationsPresenter# */
		properties: {},

		/** @lends ConfigurationErrorNotificationsPresenter# */
		methods: {
			_createPresenterView: function (presenterClass) {
				return this._createChild(presenterClass).createView();
			},
			_createHeader: function () {
				return new Heading({
					content: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_ERROR_NOTIFICATIONS_MODAL_TITLE),
					type: Heading.Type.PAGE_SUBTITLE
				})
			}
		},

		/** @lends ConfigurationErrorNotificationsPresenter# */
		overrides: {
			_onCreateView: function () {
				this._errorNotificationsPanel = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL,
					itemGap: GapSize.MEDIUM,
					outerGap: GapSize.MEDIUM,
					alignment: StackPanel.Alignment.START
				});
				this._errorNotificationsPanel.add(this._createHeader());
				this._errorNotificationsPanel.add(this._createPresenterView(ListPresenter));

				if (PermissionHelper.userHasEditPermission()) {
					this._errorNotificationsPanel.add(this._createPresenterView(SetupNotificationsButtonPresenter));
				}

				return this._errorNotificationsPanel;
			}
		}
	});

	return ConfigurationErrorNotificationsPresenter;
});