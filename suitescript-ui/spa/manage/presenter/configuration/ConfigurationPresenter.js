define('n/suitescript-ui/spa/manage/presenter/configuration/ConfigurationPresenter', [
	'n/ui/classes/Class',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/GridPanel',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/manage/presenter/configuration/ConfigurationExecuteAsPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/ConfigurationLogLevelPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/ConfigurationCenterLinksPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/ConfigurationErrorNotificationsPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/releaseAudience/ConfigurationReleaseAudiencePresenter'
], function (
	Class,
	Presenter,
	GridPanel,
	StackPanel,
	ConfigurationExecuteAsPresenter,
	ConfigurationLogLevelPresenter,
	ConfigurationCenterLinksPresenter,
	ConfigurationErrorNotificationsPresenter,
	ConfigurationReleaseAudiencePresenter
) {
	'use strict';

	var ConfigurationPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ConfigurationPresenter
		 * @extends Presenter
		 */
		initialize: function ConfigurationPresenter(options) {
			ConfigurationPresenter.$super.call(this, options);
		},

		/** @lends ConfigurationPresenter# */
		properties: {},

		/** @lends ConfigurationPresenter# */
		methods: {
			_createPresenterView: function (presenterClass) {
				return this._createChild(presenterClass).createView();
			},

			_createFields: function () {
				return [
					this._createPresenterView(ConfigurationExecuteAsPresenter),
					this._createPresenterView(ConfigurationLogLevelPresenter)
				];
			}
		},

		/** @lends ConfigurationPresenter# */
		overrides: {
			_onCreateView: function () {
				this._placeholder = new StackPanel({orientation: StackPanel.Orientation.VERTICAL});
				this._placeholder.add(new GridPanel({
					rowGap: GridPanel.GapSize.MEDIUM,
					columnGap: GridPanel.GapSize.MEDIUM,
					outerGap: GridPanel.GapSize.MEDIUM,
					columns: ['1fr', '1fr', '1fr'],
					items: this._createFields()
				}));
				this._placeholder.add(this._createPresenterView(ConfigurationReleaseAudiencePresenter))
				this._placeholder.add(this._createPresenterView(ConfigurationCenterLinksPresenter))
				this._placeholder.add(this._createPresenterView(ConfigurationErrorNotificationsPresenter))
				return this._placeholder;
			}
		}
	});

	return ConfigurationPresenter;
});