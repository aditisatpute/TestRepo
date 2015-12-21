@isTest
public class TestClass {
	static testMethod void testAngularController() {
		Contact contactInsatnce = new Contact(LastName = 'Test');
		insert contactInsatnce;
		System.assertEquals(1, TestAngularController.fetchContactList().size());
	}
	
	static testMethod void testRevenueDataTrigger() {
		RevenueData__c instance = new RevenueData__c(Name='test', validDate__c = System.today());
		insert instance;
	} 
	
	static testMethod void testRevenueDataTH() {
		RevenueData__c instance = new RevenueData__c(Name='test', validDate__c = System.today());
		insert instance;
		List<RevenueData__c> listRevenue = new List<RevenueData__c> {instance};
		Map<Id, RevenueData__c> mapIdTorevenue = new Map<Id, RevenueData__c>(listRevenue);
		RevenueDataTH.triggerHandler(true, false, false, false, false, listRevenue,mapIdTorevenue );
	} 
	
	static testMethod void testAccountDetailsController() {
		Account instance = new Account(Name='Test Acc');
		insert instance;
		AccountDetailsController.save(AccountDetailsController.updateAccountList());
	}
	
	static testMethod void testDatePickerAngularController() {
		Account instance = new Account(Name='Test Acc');
		insert instance;
		DatePickerAngularController.save(DatePickerAngularController.fetchAccountList());
	}

	static testMethod void testCustomController() {
		CustomController instance = new CustomController();
		instance.save();
	}
}