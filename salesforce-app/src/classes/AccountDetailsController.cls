public with sharing class AccountDetailsController {

    @RemoteAction
    public static List<AccountWrapper> updateAccountList() {
        List<AccountWrapper> accountWrapperList = new List<AccountWrapper>();
        for ( Account accountInstance : [
            SELECT
                Id,
                Name,
                Phone,
                RegistrationDate__c
            FROM
                Account
        ]) {
            accountWrapperList.add(
                new AccountWrapper(accountInstance)
            );
        }
        return accountWrapperList;
    }

    @RemoteAction
    public static void save(List<AccountWrapper> accountWrapperList) {
        System.debug('---accountList-->'+accountWrapperList);
        List<Account> accountList = new List<Account>();
        for (AccountWrapper accountWrapperInstance : accountWrapperList) {
            Account instance = new Account(
                Id = accountWrapperInstance.id,
                Name = accountWrapperInstance.name,
                Phone = accountWrapperInstance.phone
            );
            System.debug('----accountWrapperInstance.registrationDate--->'+accountWrapperInstance.registrationDate);
            if (accountWrapperInstance.registrationDate != '' && accountWrapperInstance.registrationDate != null) {
                instance.RegistrationDate__c = Date.parse(accountWrapperInstance.registrationDate);
            }
            accountList.add(instance);
        }
        //List<Account> accountList = (List<Account>) JSON.deserialize(accountJSONString, List<Account>.class);
        System.debug('---accountList-->'+accountList);
        if (!accountList.isEmpty()) {
            update accountList;
        }
    }


    public class AccountWrapper {
        Id id;
        String name;
        String phone;
        String registrationDate;

        public AccountWrapper(Account accountInstance) {
            id = accountInstance.Id;
            name = accountInstance.Name;
            phone = accountInstance.Phone;
            registrationDate = String.ValueOf(accountInstance.RegistrationDate__c);
        }
    }
}