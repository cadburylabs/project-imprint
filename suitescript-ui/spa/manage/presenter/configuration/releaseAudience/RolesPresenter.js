define('n/suitescript-ui/spa/manage/presenter/configuration/releaseAudience/RolesPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/Text',
	'n/ui/widgets/toolkit/layout/GapSize',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/presenter/configuration/errorNotifications/listItems/ItemComponent',
], function (
	Class,
	Object,
	Presenter,
	StackPanel,
	Text,
	GapSize,
	TranslationKeys,
	ItemComponent
) {
	'use strict';

	var RolesPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class RolesPresenter
		 * @extends Presenter
		 */
		initialize: function RolesPresenter(options) {
			this.constructor.$super.call(this, options);
		},

		/** @lends RolesPresenter# */
		properties: {},

		/** @lends RolesPresenter# */
		methods: {
			_createHeader: function () {
				return new Text({
					text: this.i18n.get(Constants.FIELD_DETAILS.TITLE),
					automationId: AutomationIds.ROLES_TITLE
				});
			},
			_clearList: function () {
				this._items.clear();
			},
			_addItemComponentToGrid: function (label, automationId) {
				this._addToGrid(new ItemComponent({
					labelName: label,
					automationId: automationId
				}));
			},
			_addToGrid: function (component) {
				this._items.add(component);
			},
			_getRoleLabel: function (roleId) {
				var role = this.state.manage.spa.audience.static.allRolesAvailable.find(
					function (role) {
						return role.id == roleId;
					});
				return role.value;
			},
			_addRoles: function () {
				if (this.state.manage.spa.audience.static.allRolesAvailable.length !== 0) {
					var that = this;
					this.state.manage.spa.audience.original.roles.roles.forEach(function (roleId) {
						that._addItemComponentToGrid(that._getRoleLabel(roleId), AutomationIds.ROLE_ITEM + roleId);
					});
				}
			},
			_addEmptyMessage: function () {
				this._addToGrid(
					new Text({
						text: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_AUDIENCE_NO_ROLES_SELECTED),
						automationId: AutomationIds.NO_ROLES_SELECTED
					}));
			},
			_rolesChanged: function () {
				this._clearList();
				this.state.manage.spa.audience.original.roles.allRoles && this._addItemComponentToGrid(
					this.i18n.get(Constants.FIELD_DETAILS.ALL_ROLES), AutomationIds.ALL_ROLES
				);
				this._addRoles();
				!this.state.manage.spa.audience.original.roles.allRoles
				&& (this.state.manage.spa.audience.original.roles.roles.length === 0) && this._addEmptyMessage();
			},
			_createItemsGrid: function () {
				this._items = new StackPanel({
					wrap: true,
					orientation: StackPanel.Orientation.HORIZONTAL
				});

				return this._items;
			}
		},

		/** @lends RolesPresenter# */
		overrides: {
			_onCreateView: function () {
				this._placeholder = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL,
					itemGap: GapSize.MEDIUM,
					alignment: StackPanel.Alignment.START
				});
				this._placeholder.add(this._createHeader());
				this._placeholder.add(this._createItemsGrid())
				this._rolesChanged();
				return this._placeholder;
			},
			_onStateChanged: function (oldState, currentState) {
				if (!Object.equals(oldState.manage.spa.audience.original.roles, currentState.manage.spa.audience.original.roles)
					|| !Object.equals(oldState.manage.spa.audience.static.allRolesAvailable, currentState.manage.spa.audience.static.allRolesAvailable)) {
					this._rolesChanged();
				}
			}
		},
		static: {
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					TITLE: TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_RELEASE_AUDIENCE_ROLES_TITLE,
					ALL_ROLES: TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_RELEASE_AUDIENCE_ROLES_ALL_ROLES_LABEL
				})
			}),
			AutomationId: Object.freeze({
				ROLES_TITLE: 'manage-spa-configuration-audience-roles-title',
				NO_ROLES_SELECTED: 'manage-spa-configuration-audience-no-roles-selected',
				ALL_ROLES: 'manage-spa-configuration-audience-roles-role-item-all-roles',
				EMPTY: 'manage-spa-configuration-audience-roles-role-item-empty',
				ROLE_ITEM: 'manage-spa-configuration-audience-roles-role-item-'
			})
		}
	});

	var Constants = RolesPresenter.Constants;
	var AutomationIds = RolesPresenter.AutomationId;

	return RolesPresenter;
});