/**
 * Trigger user to properly align revenue to Marketer statistics of a channel
 * and find proper conversion rates
 *
 * @author Aditi Satpute
 */
trigger RevenueDataTrigger on RevenueData__c (before insert) {
	System.debug('called');
    RevenueDataTH.triggerHandler(
        Trigger.isBefore,
        Trigger.isAfter,
        Trigger.isInsert,
        Trigger.isUpdate,
        Trigger.isDelete,
        Trigger.new,
        Trigger.oldMap
    );
}