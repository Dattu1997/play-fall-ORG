public class AccountTriggerHandler {

    public static void beforeDelete(List<Account> accList) {
        checkAccountContacts(accList);
    }

    public static void beforeUpdate(List<Account> acclist, Map<Id, Account> accMap){
        accountUserUpadte( accList, accMap);
        beforeUpdateAccount(accList, accMap);
    }

    public static void checkAccountContacts(List<Account> accList){
        List<Contact> conList = [SELECT Id FROM Contact WHERE AccountId In : accList ];
        System.debug('ContactData'+ conList.size());
        for(Account accObj : accList){
            if(conList.size() > 5){
                accObj.addError('sdfghj');
            }
        }
    }

    public static void accountUserUpadte(List<Account> accList, Map<Id, Account> accMap){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RecordType2').getRecordTypeId();
        string userNew;
        string userOld;

        for(Account acc : accList ){
            userNew = acc.OwnerId;
            System.debug(accMap.get(acc.Id).OwnerId);
            userOld = accMap.get(acc.Id).OwnerId;
            if(acc.recordTypeId == devRecordTypeId){
                if(userNew != userOld){
                    acc.AccountOwner__c = null;
                    acc.AccountOwnerChanged__c = 'This Account Owner is Updated';
                    acc.Type = 'Prospect';
                    acc.SLAExpirationDate__c = null;
                }
            }
        }
    }





















    public static void beforeUpdateAccount(List<Account> accNewList, Map<Id, Account> accOldMap){
        System.debug('In Before update new mothed');
        List<Task> taskList = new List<Task>();
        for(Account acc : accNewList){
            if(accOldMap.get(acc.Id).Industry != acc.Industry){
                Task task = new Task();
                task.WhatId = acc.Id;
                System.debug('task '+task);
                task.subject = 'Account Industry is changed';
                taskList.add(task);
            }
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }
}