/*
@author        A dattu        <anumanlakadidathu@playful-wolf-cz3uwx-dev-ed.my.salesforce.com>
 * @modifiedBy     A dattu       <anumanlakadidathu@rplayful-wolf-cz3uwx-dev-ed.my.salesforce.com>
 * @maintainedBy   A dattu        <anumanlakadidathu@playful-wolf-cz3uwx-dev-ed.my.salesforce.com>
 * @version        52.0
 * @created        2021-12-28
 * @modified      
 * @systemLayer    Apex Test Class
 */
 //@descrpition Testing the  contact is created on contact object
 @isTest
public with sharing class ContactControllerTest {
    

      @isTest static void getContactTest()
   {
     
    Contact conList = new Contact();
    conList.LastName='Dattu';
    conList.Email='sdf@gmail.com';
    conList.Title='CEO';
    conList.Phone='6789132465';
    conList.Department='ECE';
    conList.Birthdate=Date.newInstance(2010,07,15);
    
            Test.startTest();
            ContactController.getContacts(conList);
            
            Test.stopTest();
            System.assertEquals('Dattu',conList.LastName);

   }
}