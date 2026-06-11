define('n/suitescript-ui/spa/manage/presenter/basicInfo/actionButtons/ActionButtonsPresenter', [
	'n/ui/classes/Class',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/manage/common/FieldVisibilityHelper',
	'n/suitescript-ui/spa/manage/common/PermissionHelper',
	'n/suitescript-ui/spa/manage/presenter/basicInfo/actionButtons/DeleteAppButtonPresenter'
], function (
	Class,
	Presenter,
	StackPanel,
	FieldVisibilityHelper,
	PermissionHelper,
	DeleteAppButtonPresenter
) {
	'use strict';

	var ActionButtonsPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ActionButtonsPresenter
		 * @extends Presenter
		 */
		initialize: function ActionButtonsPresenter(options) {
			ActionButtonsPresenter.$super.call(this, options);
		},

		/** @lends ActionButtonsPresenter# */
		properties: {},

		/** @lends ActionButtonsPresenter# */
		methods: {
			_createButtons: function () {
				this._placeholder.clear();
				if (FieldVisibilityHelper.isEditable(this.state.manage.spa) && PermissionHelper.userHasFullPermission()) {
					this._placeholder.add(this._createChild(DeleteAppButtonPresenter).createView());
				}
			}
		},

		/** @lends ActionButtonsPresenter# */
		overrides: {
			_onCreateView: function () {
				this._placeholder =  new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
				});
				this._createButtons();
				return this._placeholder;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.spa.locked !== current.manage.spa.locked) {
					this._createButtons();
				}
			}
		}
	});

	return ActionButtonsPresenter;
});