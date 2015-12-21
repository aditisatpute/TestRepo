public with sharing class TestAngularController {

    /*@RemoteAction
    public static String fetchContactList() {
        List<ContactWrapper> wrapperList = new List<ContactWrapper>();
        List<Contact> contactList = [
            SELECT
                Id,
                Name,
                Phone
            FROM
                Contact
        ];

        for (Contact contactInstance : ContactList) {
            wrapperList.add(new ContactWrapper(contactInstance));
        }
        return JSON.serialize(wrapperList);
    }*/

    @RemoteAction
    public static List<Contact> fetchContactList() {
        return [
            SELECT
                Id,
                Name,
                Phone,
                RegistrationDate__c
            FROM
                Contact
        ];
    }

   /* public class ContactWrapper {
        Id id;
        String name;
        String phone;

        public ContactWrapper(Contact contactInstance) {
            id = contactInstance.Id;
            name = contactInstance.Name;
            phone = contactInstance.Phone;
        }
    }*/
}