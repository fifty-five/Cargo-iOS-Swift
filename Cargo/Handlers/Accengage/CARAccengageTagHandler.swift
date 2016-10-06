//
//  CARAccengageTagHandler.swift
//  Cargo
//
//  Created by Julien Gil on 05/10/16.
//  Copyright © 2016 55 All rights reserved.
//

import Foundation
import AccengageKit

class CARAccengageTagHandler: CARTagHandler {
    
/* ********************************* Variables Declaration ********************************* */

    let ACC_init = "ACC_init";
    let ACC_tagEvent = "ACC_tagEvent";
    let ACC_tagPurchaseEvent = "ACC_tagPurchaseEvent";
    let ACC_tagCartEvent = "ACC_tagCartEvent";
    let ACC_tagLead = "ACC_tagLead";


/* ************************************* Initializer *************************************** */

    /**
     *  Initialize the handler
     */
    init() {
        super.init(key: "ACC", name: "Accengage");

        cargo.registerTagHandler(self, key: ACC_init);
        cargo.registerTagHandler(self, key: ACC_tagEvent);
        cargo.registerTagHandler(self, key: ACC_tagPurchaseEvent);
        cargo.registerTagHandler(self, key: ACC_tagCartEvent);
        cargo.registerTagHandler(self, key: ACC_tagLead);
    }


/* ******************************** Core handler methods *********************************** */

    /**
     *  Call back from GTM container to execute a specific action
     *  after tag and parameters are received
     *
     *  @param tagName  The tag name
     *  @param parameters   Dictionary of parameters
     */
    override func execute(_ tagName: String, parameters: [AnyHashable: Any]) {
        super.execute(tagName, parameters: parameters);

        switch (tagName) {
        case ACC_init:
            self.initialize(parameters);
            break ;
        case ACC_tagEvent:
            self.tagEvent(parameters);
            break ;
        case ACC_tagPurchaseEvent:
            self.tagPurchaseEvent(parameters);
            break ;
        case ACC_tagCartEvent:
            self.tagCartEvent(parameters);
            break ;
        default:
            noTagMatch(self, tagName: tagName);
        }
    }

    /**
     *  Is called to set the tracking ID
     *
     *  @param parameters   Dictionary of parameters which should contain the partner_id and the private_key
     */
    private func initialize(_ parameters: [AnyHashable: Any]) {
        if let partnerId = parameters["partner_id"], let private_key = parameters["private_key"] {
            BMA4STracker.track(withPartnerId: partnerId as! String, privateKey: private_key as! String, options: cargo.launchOptions);
            BMA4SNotification.sharedBMA4S().didFinishLaunching(options: cargo.launchOptions);
        }
        else {
            cargo.logger.logMissingParam("partner_id and/or private_key", methodName: "ACC_init", handler: self);
        }
        if let url = parameters["url"] as! URL! {
            BMA4SNotification.sharedBMA4S().applicationHandleOpen(url);
        }
        else {
            cargo.logger.logMissingParam("url", methodName: "ACC_init", handler: self);
        }
    }


/* ********************************** Specific methods ************************************* */

    /**
     * The method used to send events to Accengage
     *
     *  @param parameters Dictionary of parameters which should contain at least the eventType
     *
     *  The event type is an integer defining the type of event. The values below 1000 are reserved for Accengage usage. 
     *  You can use custom event types starting from 1001.
     *
     *  The left content of parameters will be changed into an array of strings. All the strings in the array will be sent.
     */
    private func tagEvent(_ parameters: [AnyHashable: Any]) {
        // change the parameters as a mutable dictionary
        var parameters = parameters
        if let eventType = parameters[EVENT_TYPE] as? Int {
            // remove the entry for EVENT_TYPE in order to avoid finding it in the array of parameters
            parameters.removeValue(forKey: EVENT_TYPE);
            var tempArray = [String]()

            // rebuilding the dictionary as an array of strings
            for (key, value) in parameters {
                tempArray.append("\(key) \(value)")
            }
            // send the event
            BMA4STracker.trackEvent(withType: eventType, parameters: tempArray);
        }
        else {
            cargo.logger.logMissingParam(EVENT_TYPE, methodName: "ACC_tagEvent", handler: self);
        }
    }

    /**
     * The method used to send purchase events to Accengage
     *
     *  @param parameters Dictionary of parameters which should contain at least TRANSACTION_ID, currencyCode, 
     *  and TRANSACTION_TOTAL or TRANSACTION_PRODUCTS
     *
     *                  * TRANSACTION_ID : the ID linked to the purchase.
     *                  * currencyCode : the currency used for the transaction.
     *                  * TRANSACTION_TOTAL : the total amount of the purchase.
     *                  * TRANSACTION_PRODUCTS : an array of AccengageItem objects, the items purchased.
     */
    private func tagPurchaseEvent(_ parameters: [AnyHashable: Any]) {
        // check for the two mandatory variables
        if let purchaseId = parameters[TRANSACTION_ID] as? String, let currency = parameters["currencyCode"]  as? String {

            // check for TRANSACTION_PRODUCTS, creation of an array of accengage items
            if let itemArray = parameters[TRANSACTION_PRODUCTS] as? [AccengageItem] {
                var accItemArray = [BMA4SPurchasedItem]();
                for item in itemArray {
                    accItemArray.append(BMA4SPurchasedItem.init(id: item.id,
                                                                label: item.label,
                                                                category: item.category,
                                                                price: item.price,
                                                                quantity: item.quantity));
                }

                if let totalTransaction = parameters[TRANSACTION_TOTAL] as? Double {
                    BMA4STracker.trackPurchase(withId: purchaseId, currency: currency, items: accItemArray, totalPrice: totalTransaction);
                }
                else {
                    BMA4STracker.trackPurchase(withId: purchaseId, currency: currency, items: accItemArray);
                }
            }
            // if TRANSACTION_PRODUCTS isn't set, check for TRANSACTION_TOTAL
            else if let totalTransaction = parameters[TRANSACTION_TOTAL] as? Double {
                BMA4STracker.trackPurchase(withId: purchaseId, currency: currency, totalPrice: totalTransaction);
            }
            else {
                cargo.logger.logMissingParam("\(TRANSACTION_TOTAL) or \(TRANSACTION_PRODUCTS)", methodName: "ACC_tagPurchaseEvent", handler: self);
            }
        }
        else {
            cargo.logger.logMissingParam("\(TRANSACTION_ID) and/or currencyCode", methodName: "ACC_tagPurchaseEvent", handler: self);
        }
    }

    /**
     * The method used to report add-to-cart events to Accengage
     *
     *  @param parameters Dictionary of parameters
     *
     *                  * cartId : the ID linked to the add to cart event.
     *                  * currencyCode : the currency used for the pricing.
     *                  * product : an AccengageItem object, the one added to cart.
     */
    private func tagCartEvent(_ parameters: [AnyHashable: Any]) {
        
        if let cartId = parameters["cartId"] as? String,
            let item = parameters["product"] as? AccengageItem,
            let currency = parameters["currencyCode"] as? String {
            BMA4STracker.trackCart(withId: cartId, forArticleWithId: item.id, andLabel: item.label,
                                   category: item.category, price: item.price, currency: currency, quantity: item.quantity);
        }
        else {
            cargo.logger.logMissingParam("cartId or product or currencyCode", methodName: ACC_tagCartEvent, handler: self);
        }
    }

    /**
     * The method used to track a lead in Accengage
     *
     *  @param parameters Dictionary of parameters
     *
     *                  * leadLabel : the label.
     *                  * leadValue : the value.
     */
    func tagLead(_ parameters: [AnyHashable: Any]) {
        if let label = parameters["leadLabel"] as? String, let value = parameters["leadValue"] as? String {
            BMA4STracker.trackLead(withLabel: label, value: value);
        }
        else {
            cargo.logger.logMissingParam("leadLabel or leadValue", methodName: ACC_tagLead, handler: self);
        }
    }

/* ************************************* Utilities ***************************************** */

    /**
     * A struct in order to make it easier to transfer an item object from the application to the Accengage SDK
     */
    public struct AccengageItem {
        let id, label, category: String;
        let price: Double
        let quantity: Int;

        // All the attributes are mandatory to initialize an object from this struct.
        init(id: String, label: String, category: String, price: Double, quantity: Int) {
            self.id = id;
            self.label = label;
            self.category = category;
            self.price = price;
            self.quantity = quantity;
        }
    }
}
