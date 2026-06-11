define('n/form/plugins/CampaignSubscriptionFormPlugin', [
	'n/ui/classes/Class',
	'n/ui/form/FormPlugin',
	'n/ui/compounds/notification/UserMessageService',
	'n/ui/widgets/i18n/Translation'
], function (
	Class,
	FormPlugin,
	UserMessageService,
	Translation
) {
	'use strict';

	/**
	 * CampaignSubscriptionFormPlugin
	 *
	 * @class
	 * @extends FormPlugin
	 */
	var CampaignSubscriptionFormPlugin = Class.create({
		extend: FormPlugin,
		initialize: function CampaignSubscriptionFormPlugin(options) {
			CampaignSubscriptionFormPlugin.$super.call(this, options);
		},

		/** @lends CampaignSubscriptionFormPlugin# */
		overrides: {
			getFieldEventHandlers: function () {
				return {
					'subscribedbydefault': {
						onAfterFieldChange: function (formContext) {
							if (this.subscribedByDefaultWarning == null) {
								this.subscribedByDefaultWarning = formContext.userMessageService.warning({
									title: Translation.of({key: 'NLHeadingContext.WARNING', default: 'Warning'}),
									content: Translation.of({
										key: 'NLPagemessageContext.IF_YOU_CHOOSE_TO_SUBSCRIBE_ALL_RECIPIENTS_TO_THIS_CAMPAIGN_BY_DEFAULT_PLEASE_ENSURE_THAT_YOU_HAVE_PROVIDED_THE_APPROPRIATE_NOTICES_AND_OBTAINED_SUFFICIENT_CONSENT_TO_AUTOMATICALLY_SUBSCRIBE_NEW_AND_EXISTING_RECIPIENTS_FOR_MARKETING_MESSAGES',
										default: 'If you choose to subscribe all recipients to this campaign by default, please ensure that you have provided the appropriate notices and obtained sufficient consent to automatically subscribe new and existing recipients for marketing messages.'
									}),
									displayType: UserMessageService.DisplayType.BANNER
								});
							}

							var subscribedByDefaultField = formContext.form.findLeafViewModelById('subscribedbydefault');
							if (subscribedByDefaultField.value) {
								this.subscribedByDefaultWarning.show();
							} else {
								this.subscribedByDefaultWarning.hide();
							}
						}
					}
				};
			}
		}
	});

	return CampaignSubscriptionFormPlugin;
});