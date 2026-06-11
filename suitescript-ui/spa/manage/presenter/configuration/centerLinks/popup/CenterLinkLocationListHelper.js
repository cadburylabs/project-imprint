define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/CenterLinkLocationListHelper', [
	'n/ui/classes/Object'
], function (
	Object
) {
	'use strict';

	return Object.freeze({
		_buildCategoryItem: function (category, selectionItem) {
			var location = Object.deepCopy(selectionItem);
			location.category.id = category.id;
			location.category.value = category.value;

			return {
				id: category.id,
				value: category.value,
				location: location
			};
		},
		_buildSectionItem: function (section, selectionItem) {
			var categories = [];
			var that = this;
			selectionItem.section.id = section.id;
			selectionItem.section.value = section.value;
			section.categories.forEach(function (category) {
				categories.push(that._buildCategoryItem(category, selectionItem))
			})

			return {
				id: section.id,
				value: section.value,
				children: categories
			};
		},
		_buildCenterItem: function (center) {
			var sections = [];
			var that = this;
			var selectionItem = {
				center: {
					id: null,
					value: null
				},
				section: {
					id: null,
					value: null
				},
				category: {
					id: null,
					value: null
				}
			};
			selectionItem.center.id = center.id;
			selectionItem.center.value = center.value;
			center.sections.forEach(function (section) {
				sections.push(that._buildSectionItem(section, selectionItem))
			});

			return {
				id: center.id,
				value: center.value,
				children: sections
			};
		},
		buildCenterLinksDataSource: function (centerLinksData) {
			var dataSource = [];
			var that = this;
			centerLinksData.forEach(function (center) {
				dataSource.push(that._buildCenterItem(center));
			})

			return dataSource;
		}
	});
});
