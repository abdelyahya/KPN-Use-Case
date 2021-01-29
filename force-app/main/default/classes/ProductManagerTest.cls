/*
 * File: ProductManagerTest
 * Created Date: 29/01/2021, 5:07:02 pm
 * Author: Yahya Abdeljabar
 * -----
 * Last Modified: 29/01/2021, 5:08:02 pm
 * Modified By: Yahya Abdeljabar
 * -----
 * Purpose: ProductManager Test class 
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

@isTest
public with sharing class ProductManagerTest {

    @testSetup
    public static void createData() {
        
        //Create Product
        Product2 prod = new Product2();
        prod.Name='Test';
        prod.ProductCode='Test';
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();

        PriceBookEntry entry = new PriceBookEntry();
        entry.Pricebook2Id=pricebookId;
        entry.Product2Id=prod.id;
        entry.UnitPrice=1000.0;
        entry.IsActive=true;
        entry.UseStandardPrice=false;
        insert entry;

        //creating accout
        Account acc = new Account();
        acc.name = 'Test user';
        insert acc;

        //creating contract
        Contract cont = new Contract();
        cont.Status = 'Draft';
        cont.accountId = acc.id;
        cont.StartDate = Date.today();
        cont.ContractTerm = 12;
        insert cont;

        //creating order
        Order ord = new Order();
        ord.contractId = cont.id;
        ord.Status = 'Draft';
        ord.accountId = acc.id;
        ord.EffectiveDate = Date.today();
        ord.Pricebook2Id = pricebookId;
        insert ord;
    }

    @IsTest
    static void testingMethods(){
        Order ord = [SELECT ID FROM ORDER];
        
        system.debug(ord.id);
        Test.startTest();
        Id pricebook = ProductManager.getPriceBookId(ord.id);
        system.debug(pricebook);
        system.assertNotEquals(null, pricebook, 'pricebook id found');

        List<PricebookEntry> pricebookEntry = ProductManager.getProducts(pricebook);
        system.assertNotEquals(0, pricebookEntry.size(), 'pricebookEntry found');

        Test.stopTest();
    }
}