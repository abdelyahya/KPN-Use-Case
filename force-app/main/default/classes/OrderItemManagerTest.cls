/*
 * File: OrderItemManagerTest
 * Created Date: 29/01/2021, 5:07:02 pm
 * Author: Yahya Abdeljabar
 * -----
 * Last Modified: 29/01/2021, 5:07:48 pm
 * Modified By: Yahya Abdeljabar
 * -----
 * Purpose:Test class OrderItemManager
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

@isTest
public with sharing class OrderItemManagerTest {
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

        //Creating OrderItem
        OrderItem ordItem = new OrderItem();
        ordItem.Product2Id = prod.id;
        ordItem.OrderId = ord.id;
        ordItem.PricebookEntryId = entry.Id;
        ordItem.UnitPrice = 5000;
        ordItem.Quantity = 1;
        insert ordItem;
    }

    @IsTest
    static void testMethods(){
        Order ord = [SELECT ID FROM ORDER];
        PriceBookEntry pricebookEntry = [SELECT ID, UnitPrice FROM PriceBookEntry];
        OrderItem ordItem = [SELECT id, Quantity from orderitem];
        Product2 prod = [SELECT id from Product2];

        Test.startTest();
        //Testing the Add of quantities
        List<OrderItemManager.wrapOrderItem> myList = OrderItemManager.getOrderItems(ord.id);
        system.assertEquals(1, myList.size(), 'Order Item Found');

        OrderItemManager.createOrderItem(String.valueOf(ord.id), String.valueOf(ordItem.id), String.valueOf(pricebookEntry.Id), String.valueOf(prod.Id), pricebookEntry.unitPrice); 
        ordItem = [SELECT id, Quantity from orderitem];
        system.assertEquals(2, ordItem.Quantity, 'Quantity is modified');

        //Testing the Add of a new Product
        OrderItemManager.createOrderItem(String.valueOf(ord.id), String.valueOf(''), String.valueOf(pricebookEntry.Id), String.valueOf(prod.Id), pricebookEntry.unitPrice); 
        List<OrderItem> ordItems = [SELECT id, Quantity from orderitem];
        system.assertEquals(2, ordItems.size(), 'Order Item Added');

        Test.stopTest();
    }

}