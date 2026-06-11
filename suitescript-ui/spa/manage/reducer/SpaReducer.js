define('n/suitescript-ui/spa/manage/reducer/SpaReducer', [
	'n/ui/classes/Object',
	'n/ui/classes/app/Reducer',
	'n/ui/classes/immutable/ImmutableObject',
	'n/suitescript-ui/spa/manage/reducer/SpaAudienceReducer'
], function (
	Object,
	Reducer,
	ImmutableObject,
	SpaAudienceReducer
) {
	'use strict';

	var SpaReducer = Reducer.create({
		initialState: {
			id: '',
			name: 'Spa Name',
			description: '',
			status: '',
			url: '',
			lastUpdated: '',
			type:'',
			locked: false,
			executeAsRoleId: '',
			logLevelId: '',
			ownerId: '',
			suiteAppId: null,
			scriptDeploymentId: '',
			scriptId: '',
			usesUif: '',
			centerLinks: [],
			spaFolder: {
				id: '',
				path: ''
			},
			assetsFolder: {
				id: '',
				path: ''
			},
			clientScript: {
				parentFolderId: '',
				name: ''
			},
			serverScript: {
				parentFolderId: '',
				name: ''
			},
			errorNotifications: {
				currentUser: false,
				scriptOwner: false,
				allAdmins: false,
				userGroupId: null,
				emails: []
			},
			audience: Object.freeze(SpaAudienceReducer.initialState)
		},

		Action: {
			SET_ID: function (state, value) {
				return ImmutableObject.set(state, 'id', value);
			},
			SET_NAME: function (state, value) {
				return ImmutableObject.set(state, 'name', value);
			},
			SET_DESCRIPTION: function (state, value) {
				return ImmutableObject.set(state, 'description', value);
			},
			SET_STATUS: function (state, value) {
				return ImmutableObject.set(state, 'status', value);
			},
			SET_URL: function (state, value) {
				return ImmutableObject.set(state, 'url', value);
			},
			SET_LASTUPDATED: function (state, value) {
				return ImmutableObject.set(state, 'lastUpdated', value);
			},
			SET_EXECROLE: function (state, value) {
				return ImmutableObject.set(state, 'executeAsRoleId', value);
			},
			SET_LOGLEVEL: function (state, value) {
				return ImmutableObject.set(state, 'logLevelId', value);
			},
			SET_SCRIPT_DEPLOYMENT_ID: function (state, value) {
				return ImmutableObject.set(state, 'scriptDeploymentId', value);
			},
			SET_SCRIPT_ID: function (state, value) {
				return ImmutableObject.set(state, 'scriptId', value);
			},
			SET_OWNERID: function (state, value) {
				return ImmutableObject.set(state, 'ownerId', value);
			},
			SET_USES_UIF: function (state, value) {
				return ImmutableObject.set(state, 'usesUif', value);
			},
			SET_CENTER_LINKS: function (state, value) {
				return ImmutableObject.set(state, 'centerLinks', value);
			},
			ADD_CENTER_LINK: function (state, value) {
				var newList = Object.deepCopy(state.centerLinks);
				newList.push(value);
				return ImmutableObject.set(state, 'centerLinks', newList);
			},
			UPDATE_CENTER_LINK: function (state, payload) {
				var value = payload.linkData;
				var newList = Object.deepCopy(state.centerLinks);
				newList.forEach(function (link) {
					if (link.linkId == payload.oldLinkId) {
						link.linkId = value.linkId;
						link.label = value.label;
						link.center = value.center;
						link.section = value.section;
						link.category = value.category;
						link.insertBeforeLinkId = value.insertBeforeLinkId;
					}
				});
				return ImmutableObject.set(state, 'centerLinks', newList);
			},
			DELETE_CENTER_LINK: function (state, linkId) {
				var newList = Object.deepCopy(state.centerLinks);
				newList = newList.filter(function (link) {
					return link.linkId != linkId;
				});
				return ImmutableObject.set(state, 'centerLinks', newList);
			}
		},
		after: [{
			path: 'audience',
			reduce: SpaAudienceReducer
		}]
	});

	return SpaReducer;
});