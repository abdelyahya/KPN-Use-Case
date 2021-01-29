/*
 * File: OrderItemManager
 * Created Date: 29/01/2021, 5:07:02 pm
 * Author: Yahya Abdeljabar
 * -----
 * Last Modified: 29/01/2021, 5:07:25 pm
 * Modified By: Yahya Abdeljabar
 * -----
 * Purpose: Fetching All order Items, and also add Products to an Order
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

public with sharing class OrderItemManager {
    
    //The purpose behind this wrapper is to display reference object fields data in the lightning data table
    public class wrapOrderItem {
        @AuraEnabled 
        public Id id;
        @AuraEnabled  
        public String productId;
        @AuraEnabled
        public Decimal quantity;
        @AuraEnabled 
        public String name;
        @AuraEnabled 
        public Decimal unitPrice;
        @AuraEnabled  
        public Decimal totalPrice;   

        //constructors
        wrapOrderItem(Id id, Decimal quantity){
            this.id = id;
            this.quantity = quantity;
        } 

        wrapOrderItem(){
        }
    
        public wrapOrderItem(OrderItem oi){
            this.id = oi.id;
            this.productId = productId;
            this.quantity = oi.quantity;
            this.name = oi.Product2.name;
            this.unitPrice = oi.unitPrice;
            this.totalPrice = oi.totalPrice;
            this.productId = oi.Product2Id;
        }
    }


    @AuraEnabled(cacheable=true)  
    public static List<wrapOrderItem> getOrderItems(Id orderId){

        List<wrapOrderItem> myList = new List<wrapOrderItem>();
        wrapOrderItem tempOrdItem = new wrapOrderItem();
        List<OrderItem> oiList = [SELECT Id, Quantity, Product2.name, Product2Id,UnitPrice, TotalPrice from OrderItem  where orderid =: orderId LIMIT 200];

        if (oiList.size()>=1) {  
            for (OrderItem oi : oiList) {
                tempOrdItem = new wrapOrderItem();
                tempOrdItem.id = oi.id;
                tempOrdItem.quantity = oi.quantity;
                tempOrdItem.name = oi.Product2.name;
                tempOrdItem.unitPrice = oi.unitPrice;
                tempOrdItem.totalPrice = oi.totalPrice;
                tempOrdItem.productId = oi.Product2Id;
                myList.add(tempOrdItem);
            }
        }
        return myList;  
    }

    @AuraEnabled
    public static wrapOrderItem createOrderItem(String orderId, String orderItemId, String pricebookEntryId, String productId, Decimal unitPrice) {
                
        // I'm checking if there are any added product in orderitem with the same pricebookEntryId
        // if there are any added products with the same pricebookentry we increment the Quantity by 1
        wrapOrderItem oiWrapper;
        if(String.isNotBlank(orderItemId)){

            List<OrderItem> oiList = [ SELECT Id, Quantity from OrderItem where id=:orderItemId];
            oiList.get(0).quantity += 1;
            oiWrapper = new wrapOrderItem(oiList.get(0).Id, oiList.get(0).quantity);
            update oiList;
            return oiWrapper;  
        }
        // Otherwise we create a new product with Quantity 1    
        else{
            OrderItem ordItem = new OrderItem();
            ordItem.Product2Id = productId;
            ordItem.OrderId = orderId;
            ordItem.PricebookEntryId = pricebookEntryId;
            ordItem.UnitPrice = unitPrice;
            ordItem.Quantity = 1;
            insert ordItem;
            oiWrapper = new wrapOrderItem([SELECT Id, Quantity, Product2.name, Product2Id,UnitPrice, TotalPrice from OrderItem  where Id =: ordItem.Id]);
            return oiWrapper;
        }
    }
    
}