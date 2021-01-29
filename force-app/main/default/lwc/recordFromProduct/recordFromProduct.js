/*
 * File: RecordFromProduct
 * Created Date: 27/01/2021, 1:11:44 am
 * Author: Yahya Abdeljabar
 * -----
 * Last Modified: 29/01/2021, 11:17:11 pm
 * Modified By: Yahya Abdeljabar
 * -----
 * Purpose: 1st LWC to show all products and send required parameters to the 2nd LWC.
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */
import { LightningElement, wire, api} from 'lwc';
import { fireEvent } from 'c/pubsub'
import {CurrentPageReference} from 'lightning/navigation';
import getProducts from '@salesforce/apex/ProductManager.getProducts';
import pricebook from '@salesforce/apex/ProductManager.getPriceBookId';

export default class RecordFromProduct extends LightningElement {

    @api recordId;
    @wire(CurrentPageReference) pageRef;
    @api products;
    @api pricebookId;

    //Since we have depending parameters, it is better to avoid @wire so that way we are sure that getting the getPriceBookId is fired before getOrderableProducts
    connectedCallback() {
        if(this.recordId){
            pricebook({orderId: this.recordId}).then(pricebk => {this.pricebookId  = pricebk;
                getProducts({pricebookId: this.pricebookId}).then( product => {this.products  = product;
                });
            });
        }
    }

    productid = '';

    get responseReceived() {
        if(this.products) {
            return true;
        }
        return false;
    }
    // In this example I used pub/sub to communicate between the two LWC, 
    handleClick(event) {
        let product = this.products.filter(product => product.Id == event.currentTarget.dataset.id);
        fireEvent(this.pageRef,'addProduct', {productId:product[0].Product2Id, pricebookId : product[0].Id, unitPrice : product[0].UnitPrice});
    }
}