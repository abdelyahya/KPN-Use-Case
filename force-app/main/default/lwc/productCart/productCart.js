/*
 * File: ProductCart
 * Created Date: 29/01/2021, 5:07:02 pm
 * Author: Yahya Abdeljabar
 * -----
 * Last Modified: 29/01/2021, 5:11:50 pm
 * Modified By: Yahya Abdeljabar
 * -----
 * Purpose: 2nd LWC that shows OrderItems Added to the cart.
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

import { LightningElement, wire, api } from 'lwc';
import { registerListener } from 'c/pubsub';
import {CurrentPageReference} from 'lightning/navigation';
import getOrderItems from '@salesforce/apex/OrderItemManager.getOrderItems';
import createOrderItem from '@salesforce/apex/OrderItemManager.createOrderItem';

const COLUMNS = [
    { label: 'Quantity', fieldName: 'quantity', type: 'number' },
    { label: 'Name', fieldName: 'name', type: 'text' },
    { label: 'Price', fieldName: 'unitPrice', type: 'currency' },
    { label: 'Total Price', fieldName: 'totalPrice', type: 'currency' }
];

export default class ProductCart extends LightningElement {

    columns = COLUMNS;
    @api recordId;
    @api orderItems;

    @wire(CurrentPageReference) pageRef;
    @wire(getOrderItems, {orderId: '$recordId'})

    wiredOrder({error, data}){
        if(data){
            this.orderItems = JSON.parse(JSON.stringify(data));
        }
    };

    //Getting elements from @wire in order to modify them since a

    productid;
    
    //We listen to any event coming from the other LWC, which in our case the clik boutton 'Add to Cart'
    connectedCallback() {
        registerListener('addProduct' ,this.addProduct, this);
    }
    
    addProduct(event) {

        let orderItemId;
        let productId = event.productId;

        const result = this.orderItems.filter(ordItem => ordItem.productId == productId);

        if(result && result.length>0){
            orderItemId = result[0].id;
        }
        // We call the method create OrderItem after getting all the params
        // And we check also if there are any modifications to our orderitems
        createOrderItem({orderId : this.recordId, orderItemId : orderItemId, pricebookEntryId : event.pricebookId, productId : event.productId, unitPrice : event.unitPrice}).then( oiWrapper => {
            // if we find any orderitemId we only update the quantity in our wrapper
            if(orderItemId){
                this.orderItems.forEach(ordItem => {
                    if(ordItem.id == orderItemId){
                        ordItem.quantity = oiWrapper.quantity;
                    }
                });
            }
            // Otherwise we push a new orderitem to our Wrapper 
            else{
                this.orderItems.push(oiWrapper);
            }
            //We force the refresh of our Wrapper so the html can be refreshed
            this.orderItems = [...this.orderItems];
        })
    }
}