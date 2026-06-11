define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalLocationDropDownPicker', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/widgets/data/TreeDataSource',
	'n/ui/widgets/toolkit/TreeView',
	'n/ui/widgets/toolkit/picker/Picker',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/CenterLinksHelper'
], function (
	Class,
	Object,
	TreeDataSource,
	TreeView,
	Picker,
	CenterLinksHelper
) {
	'use strict';

	var StatementPicker = Class.create({
		extend: Picker,

		/**
		 * @class StatementPicker
		 * @extends Picker
		 *
		 * @param {Object} options
		 * @param {Array} options.locationsTree
		 */
		initialize: function StatementPicker(options) {
			this.locationsTreeDataSource = options.dataSource;
			StatementPicker.$super.call(this, options);
		},

		/** @lends StatementPicker# */
		properties: {
			dataSource: {
				writable: true,
				afterChange: function(oldValue, currentValue) {
					this._updateDataSource(currentValue);
				}
			}
		},

		/** @lends StatementPicker# */
		methods: {
			_updateDataSource: function (dataSource) {
				this.locationsTreeDataSource = dataSource;
				if(this._locationsTree)
					this._locationsTree.setDataSource(dataSource);
			},
			_customizeItem: function (item) {
				var data = item.dataItem;
				var children = data.children;
				item.selectable = !children || children.length === 0; // Only leafs
				item.automationId = AutomationIds.TREE_VIEW + '-' + data.id;
			},
			_locationChanged: function (args) {
				var selectedItem = Object.deepCopy(args.currentItems[0]);
				selectedItem.locationDescription = CenterLinksHelper.getLinkLocation(selectedItem.location);

				this._changeSelection({
					selectedItems: [selectedItem],
					unselectedItems: [args.oldItems[0]],
					reason: args.reason
				});
				this.close();
			},
			_treeViewExpanded: function () {
				this._window.resize();
			}
		},

		overrides: {
			_createContent: function (contentOptions) {
				this._locationsTree = new TreeView({
					automationId: AutomationIds.TREE_VIEW,
					ariaLabel: AutomationIds.TREE_VIEW,
					dataSource: new TreeDataSource({data: this.locationsTreeDataSource}),
					displayMember: 'value',
					customizeItem: this._customizeItem
				});
				this._locationsTree.on(TreeView.Event.SELECTION_CHANGED, this._locationChanged.bind(this));
				this._locationsTree.on(TreeView.Event.ITEM_EXPANDED, this._treeViewExpanded.bind(this));
				this._locationsTree.rootStyle.set('border', 'none');

				return this._locationsTree;
			}
		},

		static: {
			AutomationIds: Object.freeze({
				TREE_VIEW: 'manage-spa-configuration-center-link-modal-locations-tree'
			})
		}
	});

	var AutomationIds = StatementPicker.AutomationIds;

	return StatementPicker;
});
