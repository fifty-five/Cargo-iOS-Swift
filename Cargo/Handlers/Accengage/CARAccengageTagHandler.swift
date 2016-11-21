//
//  CARAccengageTagHandler.swift
//  Cargo
//
//  Created by Julien Gil on 05/10/16.
//  Copyright © 2016 55 All rights reserved.
//

import Foundation
import AccengageKit


/// The class which handles interactions with the Accengage SDK.
class CARAccengageTagHandler: CARTagHandler {
    
/* *********************************** Variables Declaration ************************************ */

    /** Constants used to define callbacks in the register and in the execute method */
    let ACC_init = "ACC_init";
    let ACC_tagEvent = "ACC_tagEvent";
    let ACC_tagPurchaseEvent = "ACC_tagPurchaseEvent";
    let ACC_tagCartEvent = "ACC_tagCartEvent";
    let ACC_tagLead = "ACC_tagLead";
    let ACC_updateDeviceInfo = "ACC_updateDeviceInfo";


/* ********************************** Handler core methods ************************************** */

    /// Called to instantiate the handler with its key and name properties.
    /// Register the callbacks to the container. After a dataLayer.push(),
    /// these will trigger the execute method of this handler.
    init() {
        super.init(key: "ACC", name: "Accengage");

        cargo.registerTagHandler(self, key: ACC_init);
        cargo.registerTagHandler(self, key: ACC_tagEvent);
        cargo.registerTagHandler(self, key: ACC_tagPurchaseEvent);
        cargo.registerTagHandler(self, key: ACC_tagCartEvent);
        cargo.registerTagHandler(self, key: ACC_tagLead);
        cargo.registerTagHandler(self, key: ACC_updateDeviceInfo);
    }

    /// Callback from GTM container designed to execute a specific method
    /// from its tag and the parameters received.
    ///
    /// - Parameters:
    ///   - tagName: the tag name of the aimed method
    ///   - parameters: Dictionary of parameters
    override func execute(_ tagName: String, parameters: [AnyHashable: Any]) {
        super.execute(tagName, parameters: parameters);

        if (tagName == ACC_init) {
            self.initialize(parameters);
            return ;
        }
        // check whether the SDK has been initialized before calling any method
        else if (self.initialized) {
            switch (tagName) {
                case ACC_tagEvent:
                    self.tagEvent(parameters);
                    break ;
                case ACC_tagPurchaseEvent:
                    self.tagPurchaseEvent(parameters);
                    break ;
                case ACC_tagCartEvent:
                    self.tagCartEvent(parameters);
                    break ;
                case ACC_tagLead:
                    self.tagLead(parameters);
                    break ;
                case ACC_updateDeviceInfo:
                    self.updateDeviceInfo(parameters);
                    break ;
                default:
                    noTagMatch(self, tagName: tagName);
            }
        }
        else {
            cargo.logger.logUninitializedFramework(self);
        }
    }

    
/* ************************************ SDK initialization ************************************** */

    /// The method you need to call first. Allow you to initialize Accengage SDK
    /// Register the private key and the partner ID to the Accengage SDK.
    ///
    /// - Parameters:
    ///   - privateKey: private key Accengage gives when you register your app
    ///   - partnerId: partner ID Accengage gives when you register your app
    private func initialize(_ parameters: [AnyHashable: Any]) {
        if let partnerId = parameters["partnerId"], let privateKey = parameters["privateKey"] {
            BMA4STracker.track(withPartnerId: partnerId as! String,
                               privateKey: privateKey as! String,
                               options: cargo.launchOptions);
            // the SDK is now initialized
            self.initialized = true;
            cargo.logger.logParamSetWithSuccess("partnerId", value: partnerId, handler: self);
            cargo.logger.logParamSetWithSuccess("privateKey", value: privateKey, handler: self);
        }
        else {
            cargo.logger.logMissingParam("partner_id and/or private_key",
                                         methodName: "ACC_init", handler: self);
        }
    }


/* ****************************************** Tracking ****************************************** */

    /// Method used to create and fire an event to the Accengage interface
    /// The mandatory parameter is EVENT_ID which is a necessity to build the event.
    ///
    /// - Parameters:
    ///   - eventId: an integer defining the type of event.
    ///              The values below 1000 are reserved for Accengage usage.
    ///              You can use custom event types starting from 1001.
    ///   - other parameters: will be changed into an array of strings build from key + value. 
    ///                       All the strings in the array will be sent.
    private func tagEvent(_ parameters: [AnyHashable: Any]) {
        // change the parameters as a mutable dictionary
        var parameters = parameters
        if let eventType = parameters[EVENT_TYPE] as? Int {
            // remove the entry for EVENT_TYPE in order to avoid finding it in the array of parameters
            parameters.removeValue(forKey: EVENT_TYPE);
            var tempArray = [String]()

            // rebuilding the dictionary as an array of strings
            for (key, value) in parameters {
                tempArray.append("\(key): \(value)")
            }
            // send the event
            BMA4STracker.trackEvent(withType: eventType, parameters: tempArray);
        }
        else {
            cargo.logger.logMissingParam(EVENT_TYPE, methodName: "ACC_tagEvent", handler: self);
        }
    }

    /// The method used to report a purchase in your app in Accengage.
    /// TRANSACTION_ID, TRANSACTION_CURRENCY_CODE are required.
    /// TRANSACTION_TOTAL and/or TRANSACTION_PRODUCTS is required.
    ///
    /// - Parameters:
    ///   - transactionId : the ID linked to the purchase.
    ///   - transactionCurrencyCode : the currency used for the transaction.
    ///   - transactionTotal : the total amount of the purchase.
    ///   - transactionProducts : an array of AccengageItem objects, the items purchased.
    private func tagPurchaseEvent(_ parameters: [AnyHashable: Any]) {
        // check for the two mandatory variables
        if let purchaseId = parameters[TRANSACTION_ID] as? String,
            let currency = parameters[TRANSACTION_CURRENCY_CODE]  as? String {

            // check for TRANSACTION_PRODUCTS. If it exists, creation of an array of accengage items
            if let itemArray = parameters[TRANSACTION_PRODUCTS] as? [AccengageItem] {
                var accItemArray = [BMA4SPurchasedItem]();
                // change the type of the items through the toItem() method
                for item in itemArray {
                    accItemArray.append(item.toItem());
                }
                // send the event with the TRANSACTION_TOTAL if it exists
                if let totalTransaction = parameters[TRANSACTION_TOTAL] as? Double {
                    BMA4STracker.trackPurchase(withId: purchaseId, currency: currency,
                                               items: accItemArray, totalPrice: totalTransaction);
                }
                // send the event without TRANSACTION_TOTAL as it doesn't exist
                else {
                    BMA4STracker.trackPurchase(withId: purchaseId, currency: currency,
                                               items: accItemArray);
                }
            }
            // if TRANSACTION_PRODUCTS isn't set, check for TRANSACTION_TOTAL
            else if let totalTransaction = parameters[TRANSACTION_TOTAL] as? Double {
                BMA4STracker.trackPurchase(withId: purchaseId, currency: currency,
                                           totalPrice: totalTransaction);
            }
            // either TRANSACTION_PRODUCTS or TRANSACTION_TOTAL is mandatory parameter
            else {
                cargo.logger.logMissingParam("\(TRANSACTION_TOTAL) or \(TRANSACTION_PRODUCTS)",
                    methodName: "ACC_tagPurchaseEvent",
                    handler: self);
            }
        }
        else {
            cargo.logger.logMissingParam("\(TRANSACTION_ID) and/or \(TRANSACTION_CURRENCY_CODE)",
                methodName: "ACC_tagPurchaseEvent",
                handler: self);
        }
    }

    /// The method used to report an "add to cart" event to Accengage. It logs the id of the cart,
    /// the currency code and the item which has been added. All the parameters are mandatory.
    ///
    /// - Parameters:
    ///   - transactionId : the id associated to this cart.
    ///   - transactionCurrencyCode : the currency used for the transaction.
    ///   - item : the item which is added to the cart.
    private func tagCartEvent(_ parameters: [AnyHashable: Any]) {
        
        // check for the three mandatory parameters
        if let cartId = parameters["cartId"] as? String,
            let item = parameters["product"] as? AccengageItem,
            let currency = parameters["currencyCode"] as? String {
            // create and send the add-to-cart event
            BMA4STracker.trackCart(withId: cartId, forArticleWithId: item.id,
                                   andLabel: item.label,
                                   category: item.category, price: item.price,
                                   currency: currency, quantity: item.quantity);
        }
        else {
            cargo.logger.logMissingParam("cartId or product or currencyCode",
                                         methodName: ACC_tagCartEvent, handler: self);
        }
    }

    /// The method used to create and fire a custom lead to Accengage.
    /// Both parameters are mandatory.
    ///
    /// - Parameters:
    ///   - leadLabel : label of the lead
    ///   - leadValue : value of the lead
    func tagLead(_ parameters: [AnyHashable: Any]) {
        if let label = parameters["leadLabel"] as? String, let value = parameters["leadValue"] as? String {
            BMA4STracker.trackLead(withLabel: label, value: value);
        }
        else {
            cargo.logger.logMissingParam("leadLabel or leadValue", methodName: ACC_tagLead, handler: self);
        }
    }

    /// A device profile is a set of key/value that are uploaded to Accengage server.
    /// You can create a device profile for each device in order to qualify the profile
    /// (for example, registering whether the user is opt in for or
    /// out of some categories of notifications).
    /// In order to update information about a device profile, use this method.
    ///
    /// - Parameter parameters: a dictionary of parameters to update the profile with.
    func updateDeviceInfo(_ parameters: [AnyHashable: Any]) {
        BMA4STracker.updateDeviceInfo(parameters);
    }


/* ****************************************** Utility ******************************************* */

    /// A struct designed to make it easier to send an item object from the app to the Accengage SDK
    public struct AccengageItem {
        let id, label, category: String;
        let price: Double
        let quantity: Int;

        /// The constructor of an item
        ///
        /// - Parameters:
        ///   - id: the item id
        ///   - label: label describing the item
        ///   - category: category the item belongs to
        ///   - price: price of the item
        ///   - quantity: quantity of item concerned
        init(id: String, label: String, category: String, price: Double, quantity: Int) {
            self.id = id;
            self.label = label;
            self.category = category;
            self.price = price;
            self.quantity = quantity;
        }
        
        
        /// cast instantly a custom AccengageItem to a BMA4SPurchasedItem
        ///
        /// - Returns: a proper instantiated BMA4SPurchasedItem
        func toItem() -> BMA4SPurchasedItem {
            return BMA4SPurchasedItem.init(id: self.id,
                                           label: self.label,
                                           category: self.category,
                                           price: self.price,
                                           quantity: self.quantity);
        }
    }
}
