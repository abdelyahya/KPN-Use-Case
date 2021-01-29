/*
 * File: ProductManager
 * Created Date: 27/01/2021, 11:51:18 am
 * Author: Yahya Abdeljabar
 * -----
 * Last Modified: 27/01/2021, 11:54:06 am
 * Modified By: Yahya Abdeljabar
 * -----
 * Purpose: Fetching data from pricebookentry and show in the 1st LWC
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

public with sharing class ProductManager {

    @AuraEnabled(cacheable=true)
    public static String getPriceBookId(String orderId) {
        List<Order> ord =  [SELECT id, Pricebook2Id from Order where Id =: orderId];
        return ord[0].Pricebook2Id;
    }

    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProducts(String pricebookId) {
        List<PricebookEntry> priceBookEntryList = [SELECT Id, Name, UnitPrice, Pricebook2Id, Product2Id from PricebookEntry where Pricebook2Id =: pricebookId And pricebook2.IsActive = true ];
        return priceBookEntryList;
    }
}