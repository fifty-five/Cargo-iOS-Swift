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
    let ACC_INIT = "ACC_init";
    let ACC_TAG_EVENT = "ACC_tagEvent";
    let ACC_TAG_PURCHASE = "ACC_tagPurchase";
    let ACC_ADD_TO_CART = "ACC_tagAddToCart";
    let ACC_TAG_LEAD = "ACC_tagLead";
    let ACC_UPDATE_DEVICE_INFO = "ACC_updateDeviceInfo";

    let PARTNER_ID = "partnerId";
    let PRIVATE_KEY = "privateKey";


/* ********************************** Handler core methods ************************************** */

    /// Called to instantiate the handler with its key and name properties.
    /// Register the callbacks to the container. After a dataLayer.push(),
    /// these will trigger the execute method of this handler.
    init() {
        super.init(key: "ACC", name: "Accengage");

        cargo.registerTagHandler(self, key: ACC_INIT);
        cargo.registerTagHandler(self, key: ACC_TAG_EVENT);
        cargo.registerTagHandler(self, key: ACC_TAG_PURCHASE);
        cargo.registerTagHandler(self, key: ACC_ADD_TO_CART);
        cargo.registerTagHandler(self, key: ACC_TAG_LEAD);
        cargo.registerTagHandler(self, key: ACC_UPDATE_DEVICE_INFO);
    }

    /// Callback from GTM container designed to execute a specific method
    /// from its tag and the parameters received.
    ///
    /// - Parameters:
    ///   - tagName: the tag name of the aimed method
    ///   - parameters: Dictionary of parameters
    override func execute(_ tagName: String, parameters: [AnyHashable: Any]) {
        super.execute(tagName, parameters: parameters);

        if (tagName == ACC_INIT) {
            self.initialize(parameters);
            return ;
        }
        // check whether the SDK has been initialized before calling any method
        else if (self.initialized) {
            switch (tagName) {
                case ACC_TAG_EVENT:
                    self.tagEvent(parameters);
                    break ;
                case ACC_TAG_PURCHASE:
                    self.tagPurchaseEvent(parameters);
                    break ;
                case ACC_ADD_TO_CART:
                    self.tagCartEvent(parameters);
                    break ;
                case ACC_TAG_LEAD:
                    self.tagLead(parameters);
                    break ;
                case ACC_UPDATE_DEVICE_INFO:
                    self.updateDeviceInfo(parameters);
                    break ;
                default:
                    logger.logUnknownFunctionTag(tagName);
            }
        }
        else {
            logger.logUninitializedFramework();
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
        if let partnerId = parameters[PARTNER_ID], let privateKey = parameters[PRIVATE_KEY] {
            BMA4STracker.track(withPartnerId: partnerId as! String,
                               privateKey: privateKey as! String,
                               options: cargo.launchOptions);
            // the SDK is now initialized
            self.initialized = true;
            logger.logParamSetWithSuccess(PARTNER_ID, value: partnerId);
            logger.logParamSetWithSuccess(PRIVATE_KEY, value: privateKey);
            logger.logParamSetWithSuccess("launchOptions", value: cargo.launchOptions);
        }
        else {
            logger.logMissingParam("\([PARTNER_ID, PRIVATE_KEY])", methodName: ACC_INIT);
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

        if let eventId = parameters[EVENT_ID] as? Int {
            // remove the entry for EVENT_TYPE in order to avoid finding it in the array of parameters
            parameters.removeValue(forKey: EVENT_ID);
            var tempArray = [String]();

            // rebuilding the dictionary as an array of strings
            for (key, value) in parameters {
                tempArray.append("\(key): \(value)");
            }
            // send the event
            BMA4STracker.trackEvent(withType: eventId, parameters: tempArray);
            logger.logParamSetWithSuccess(EVENT_ID, value: eventId);
            logger.logParamSetWithSuccess("parameters", value: tempArray);
        }
        else {
            logger.logMissingParam(EVENT_ID, methodName: ACC_TAG_EVENT);
        }
    }

    /// The method used to create and fire a custom lead to Accengage.
    /// Both parameters are mandatory.
    ///
    /// - Parameters:
    ///   - leadLabel : label of the lead
    ///   - leadValue : value of the lead
    func tagLead(_ parameters: [AnyHashable: Any]) {
        let LEAD_LABEL = "leadLabel";
        let LEAD_VALUE = "leadValue";
        
        if let label = parameters[LEAD_LABEL] as? String,
            let value = parameters[LEAD_VALUE] as? String {
            BMA4STracker.trackLead(withLabel: label, value: value);
            logger.logParamSetWithSuccess(LEAD_LABEL, value: label);
            logger.logParamSetWithSuccess(LEAD_VALUE, value: value);
        }
        else {
            logger.logMissingParam("\([LEAD_LABEL, LEAD_VALUE])", methodName: ACC_TAG_LEAD);
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
        if let cartId = parameters[TRANSACTION_ID] as? String,
            let item = parameters["item"] as? AccengageItem,
            let currency = parameters[TRANSACTION_CURRENCY_CODE] as? String {
            // create and send the add-to-cart event
            BMA4STracker.trackCart(withId: cartId, forArticleWithId: item.id,
                                   andLabel: item.label,
                                   category: item.category, price: item.price,
                                   currency: currency, quantity: item.quantity);
            logger.logParamSetWithSuccess(TRANSACTION_ID, value: cartId);
            logger.logParamSetWithSuccess(TRANSACTION_CURRENCY_CODE, value: currency);
            logger.logParamSetWithSuccess("item", value: item);
        }
        else {
            logger.logMissingParam("\([TRANSACTION_ID, TRANSACTION_CURRENCY_CODE, "item"])",
                methodName: ACC_ADD_TO_CART);
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
            if let accItemArray = parameters[TRANSACTION_PRODUCTS] as? [AccengageItem] {
                var BMA4SItemArray = [BMA4SPurchasedItem]();
                // change the type of the items through the toItem() method
                for accItem in accItemArray {
                    BMA4SItemArray.append(accItem.toBMA4SItem());
                }
                // send the event with the TRANSACTION_TOTAL if it exists
                if let totalTransaction = parameters[TRANSACTION_TOTAL] as? Double {
                    BMA4STracker.trackPurchase(withId: purchaseId, currency: currency,
                                               items: BMA4SItemArray, totalPrice: totalTransaction);
                    logger.logParamSetWithSuccess(TRANSACTION_ID, value: purchaseId);
                    logger.logParamSetWithSuccess(TRANSACTION_CURRENCY_CODE, value: currency);
                    logger.logParamSetWithSuccess(TRANSACTION_TOTAL, value: totalTransaction);
                    logger.logParamSetWithSuccess(TRANSACTION_PRODUCTS, value: accItemArray);
                    return ;
                }
                // send the event without TRANSACTION_TOTAL as it doesn't exist
                else {
                    BMA4STracker.trackPurchase(withId: purchaseId, currency: currency,
                                               items: accItemArray);
                    logger.logParamSetWithSuccess(TRANSACTION_ID, value: purchaseId);
                    logger.logParamSetWithSuccess(TRANSACTION_CURRENCY_CODE, value: currency);
                    logger.logParamSetWithSuccess(TRANSACTION_PRODUCTS, value: accItemArray);
                    return ;
                }
            }
            // if TRANSACTION_PRODUCTS isn't set, check for TRANSACTION_TOTAL
            else if let totalTransaction = parameters[TRANSACTION_TOTAL] as? Double {
                BMA4STracker.trackPurchase(withId: purchaseId, currency: currency,
                                           totalPrice: totalTransaction);
                logger.logParamSetWithSuccess(TRANSACTION_ID, value: purchaseId);
                logger.logParamSetWithSuccess(TRANSACTION_CURRENCY_CODE, value: currency);
                logger.logParamSetWithSuccess(TRANSACTION_TOTAL, value: totalTransaction);
                return ;
            }
            // either TRANSACTION_PRODUCTS or TRANSACTION_TOTAL is mandatory parameter
            else {
                logger.logMissingParam("\([TRANSACTION_TOTAL, TRANSACTION_PRODUCTS])",
                    methodName: ACC_TAG_PURCHASE);
            }
        }
        else {
            logger.logMissingParam("\([TRANSACTION_ID, TRANSACTION_CURRENCY_CODE])",
                methodName: ACC_TAG_PURCHASE);
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
        if (parameters.count > 0) {
            BMA4STracker.updateDeviceInfo(parameters);
            logger.logParamSetWithSuccess("device infos", value: parameters);
        }
        else {
            let message = "No parameters have been given for the method \(ACC_UPDATE_DEVICE_INFO)";
            logger.carLog(kTAGLoggerLogLevelWarning, message: message);
        }
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
        func toBMA4SItem() -> BMA4SPurchasedItem {
            return BMA4SPurchasedItem.init(id: self.id,
                                           label: self.label,
                                           category: self.category,
                                           price: self.price,
                                           quantity: self.quantity);
        }
    }
}
