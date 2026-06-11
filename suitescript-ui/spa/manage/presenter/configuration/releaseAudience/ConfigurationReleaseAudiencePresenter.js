define('n/suitescript-ui/spa/manage/presenter/configuration/releaseAudience/ConfigurationReleaseAudiencePresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/Heading',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/layout/GapSize',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/PermissionHelper',
	'n/suitescript-ui/spa/manage/presenter/configuration/releaseAudience/NoAudienceSettedBannerPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/releaseAudience/RolesPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/releaseAudience/SetupAudienceButtonPresenter',
	'n/suitescript-ui/spa/manage/reducer/SpaAudienceReducer'
], function (
	Class,
	Object,
	Presenter,
	Heading,
	StackPanel,
	GapSize,
	ServiceList,
	TranslationKeys,
	PermissionHelper,
	NoAudienceSettedBannerPresenter,
	RolesPresenter,
	SetupAudienceButtonPresenter,
	SpaAudienceReducer
) {
	'use strict';

	var ConfigurationReleaseAudiencePresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ConfigurationReleaseAudiencePresenter
		 * @extends Presenter
		 */
		initialize: function ConfigurationReleaseAudiencePresenter(options) {
			this.constructor.$super.call(this, options);

			this._spaService = this.context.services.get(ServiceList.SPA);
			this._rolesService = this.context.services.get(ServiceList.ROLES);
		},

		/** @lends ConfigurationReleaseAudiencePresenter# */
		properties: {},

		/** @lends ConfigurationReleaseAudiencePresenter# */
		methods: {
			_createPresenterView: function (presenterClass) {
				return this._createChild(presenterClass).createView();
			},
			_createHeader: function () {
				return new Heading({
					content: this.i18n.get(Constants.FIELD_DETAILS.TITLE),
					type: Heading.Type.PAGE_SUBTITLE
				});
			},
			_spaAudienceLoaded: function (response) {
				this.dispatchAction(SpaAudienceReducer.Action.AUDIENCE_RECEIVED, response.response);
			},
			_loadSpaAudience: function () {
				if (this.state.manage.spa.id !== "") {
					this._spaService.getAudience(this.state.manage.spa.id)
						.then(this._spaAudienceLoaded.bind(this));
				}
			},
			_deploymentChangedAction: function () {
				this._loadAllRolesAvailable();
			},
			_loadAllRolesAvailable: function() {
				if (this.state.manage.spa.scriptDeploymentId !== "") {
					this._rolesService.getAudienceRoleList(this.state.manage.spa.scriptDeploymentId)
						.then(this._allRolesAvailableLoaded.bind(this));
				}
				else {
					this.dispatchAction(SpaAudienceReducer.Action.AVAILABLE_ROLES_RECEIVED, []);
				}
			},
			_allRolesAvailableLoaded: function (allRolesAvailable) {
				this.dispatchAction(SpaAudienceReducer.Action.AVAILABLE_ROLES_RECEIVED, allRolesAvailable);
			}
		},

		/** @lends ConfigurationReleaseAudiencePresenter# */
		overrides: {
			_onCreateView: function () {
				this._loadSpaAudience();
				this._placeholder = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL,
					itemGap: GapSize.MEDIUM,
					outerGap: GapSize.MEDIUM,
					alignment: StackPanel.Alignment.START
				});
				this._placeholder.add(this._createHeader());
				this._placeholder.add(this._createPresenterView(NoAudienceSettedBannerPresenter));
				this._placeholder.add(this._createPresenterView(RolesPresenter));

				if (PermissionHelper.userHasEditPermission()) {
					this._placeholder.add(this._createPresenterView(SetupAudienceButtonPresenter));
				}
				return this._placeholder;
			},
			_onStateChanged: function (oldState, currentState) {
				if (oldState.manage.spa.id !== currentState.manage.spa.id) {
					this._loadSpaAudience();
				}
				if (oldState.manage.spa.scriptDeploymentId !== currentState.manage.spa.scriptDeploymentId) {
					this._deploymentChangedAction();
				}
			}
		},
		static: {
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					TITLE: TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_RELEASE_AUDIENCE_TITLE
				})
			})
		}
	});
	var Constants = ConfigurationReleaseAudiencePresenter.Constants;

	return ConfigurationReleaseAudiencePresenter;
});