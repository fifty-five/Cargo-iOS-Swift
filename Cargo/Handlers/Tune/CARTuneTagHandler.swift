//
//  CARTuneTagHandler.swift
//  Cargo
//
//  Created by Julien Gil on 30/08/16.
//  Copyright © 2016 fifty-five All rights reserved.
//

import Foundation


/// The class which handles interactions with the Tune SDK.
class CARTuneTagHandler: CARTagHandler {

/* *********************************** Variables Declaration ************************************ */

    /** Constants used to define callbacks in the register and in the execute method */
    let TUN_INIT = "TUN_init";
    let TUN_SESSION = "TUN_measureSession";
    let TUN_IDENTIFY = "TUN_identify";
    let TUN_TAG_EVENT = "TUN_tagEvent";

    let ADVERTISER_ID = "advertiserId";
    let CONVERSION_KEY = "conversionKey";

    /** All the parameters that could be set as attributes to a TuneEvent object */
    let EVENT_RATING = "eventRating";
    let EVENT_DATE1 = "eventDate1";
    let EVENT_DATE2 = "eventDate2";
    let EVENT_REVENUE = "eventRevenue";
    let EVENT_ITEMS = "eventItems";
    let EVENT_LEVEL = "eventLevel";
    let EVENT_RECEIPT = "eventReceipt";
    let EVENT_QUANTITY = "eventQuantity";
    let EVENT_TRANSACTION_STATE = "eventTransactionState";

    /** the formatted name "eventRandomAttribute" is important here as the string is used in the
     eventBuilder method to call on TuneEvent methods. */
    let EVENT_STRING_PROPERTIES: [String] = ["eventCurrencyCode", "eventRefId",
                                      "eventContentId", "eventContentType",
                                      "eventSearchString", "eventAttribute1",
                                      "eventAttribute2", "eventAttribute3",
                                      "eventAttribute4", "eventAttribute5"];

    var EVENT_MIXED_PROPERTIES: [String];

/* ************************************ Handler core methods ************************************ */

    /// Called to instantiate the handler with its key and name properties.
    /// Enable or disable the Tune debug mode, based on the log level activated in the Cargo logger
    /// Register the callbacks to the container. After a dataLayer.push(),
    /// these will trigger the execute method of this handler.
    init() {
        EVENT_MIXED_PROPERTIES = [EVENT_RATING, EVENT_DATE1, EVENT_DATE2,
                                  EVENT_REVENUE, EVENT_ITEMS, EVENT_LEVEL,
                                  EVENT_RECEIPT, EVENT_QUANTITY, EVENT_TRANSACTION_STATE];

        super.init(key: "TUN", name: "Tune");

        // enables Tune debug mode if the cargo logger is set to verbose, disables it otherwise
        if (cargo.tagManager.logger.logLevel() == kTAGLoggerLogLevelVerbose) {
            Tune.setDebugMode(true);
        } else {
            Tune.setDebugMode(false);
        }

        cargo.registerTagHandler(self, key: TUN_INIT);
        cargo.registerTagHandler(self, key: TUN_SESSION);
        cargo.registerTagHandler(self, key: TUN_IDENTIFY);
        cargo.registerTagHandler(self, key: TUN_TAG_EVENT);
    }

    /// Callback from GTM container designed to execute a specific method
    /// from its tag and the parameters received.
    ///
    /// - Parameters:
    ///   - tagName: the tag name of the aimed method
    ///   - parameters: Dictionary of parameters
    override func execute(_ tagName: String, parameters: [AnyHashable: Any]) {
        super.execute(tagName, parameters: parameters);

        if (tagName == TUN_INIT) {
            self.initialize(parameters);
        }
        // check whether the SDK has been initialized before calling any method
        else if (self.initialized) {
            switch (tagName) {
                case TUN_SESSION:
                    self.measureSession();
                    break ;
                case TUN_IDENTIFY:
                    self.identify(parameters);
                    break ;
                case TUN_TAG_EVENT:
                    self.tagEvent(parameters);
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

    /// The method you need to call first. Allow you to initialize Tune SDK
    /// Register the advertiserId & conversionKey to the Tune SDK.
    ///
    /// - Parameters:
    ///   - advertiserId: advertiser ID Tune gives when you register your app
    ///   - conversionKey: conversion key Tune gives when you register your app
    func initialize(_ parameters: [AnyHashable: Any]) {
        if let advertiserId = parameters[ADVERTISER_ID],
            let conversionKey = parameters[CONVERSION_KEY] {
            Tune.initialize(withTuneAdvertiserId: advertiserId as! String,
                            tuneConversionKey: conversionKey as! String);
            // the SDK is now initialized
            self.initialized = true;
            logger.logParamSetWithSuccess(ADVERTISER_ID, value: advertiserId);
            logger.logParamSetWithSuccess(CONVERSION_KEY, value: conversionKey);
        }
        else {
            logger.logMissingParam("\([ADVERTISER_ID, CONVERSION_KEY])", methodName: TUN_INIT);
        }
    }

/* ****************************************** Tracking ****************************************** */

    /// Use it in AppDelegate in the method "applicationDidBecomeActive"
    /// Attribution will not function without the measureSession call included.
    fileprivate func measureSession() {
        Tune.measureSession();
        self.logger.carLog(kTAGLoggerLogLevelInfo, message:"Measure session hit has been sent.");
    }

    /// Used in order to identify the user as a unique visitor and to associate to a unique id
    /// the related social networks ids, age, mail, username, gender...
    ///
    /// - Parameters:
    ///   - userId (String) : an identifier attributed to a unique user (mandatory param)
    ///   - userGoogleId (String) : the google id if your user logged in with
    ///   - userFacebookId (String) : the facebook id if your user logged in with
    ///   - userTwitterId (String) : the twitter id if your user logged in with
    ///   - userAge (String) : the age of your user
    ///   - userName (String) : the username/name of your user
    ///   - userEmail (String) : the mail adress of your user
    ///   - userGender (String) : the gender of your user (MALE/FEMALE/UNKNOWN)
    fileprivate func identify(_ parameters: [AnyHashable: Any]) {

        if let userId = parameters[USER_ID] {
            Tune.setUserId(userId as! String);
            logger.logParamSetWithSuccess(USER_ID, value: userId);
        }
        if let userFacebookId = parameters[USER_FACEBOOK_ID] {
            Tune.setFacebookUserId(userFacebookId as! String);
            logger.logParamSetWithSuccess(USER_FACEBOOK_ID, value: userFacebookId);
        }
        if let userGoogleId = parameters[USER_GOOGLE_ID] {
            Tune.setGoogleUserId(userGoogleId as! String);
            logger.logParamSetWithSuccess(USER_GOOGLE_ID, value: userGoogleId);
        }
        if let userTwitterId = parameters[USER_TWITTER_ID] {
            Tune.setTwitterUserId(userTwitterId as! String);
            logger.logParamSetWithSuccess(USER_TWITTER_ID, value: userTwitterId);
        }
        if let userName = parameters[USER_NAME] {
            Tune.setUserName(userName as! String);
            logger.logParamSetWithSuccess(USER_NAME, value: userName);
        }
        if let userAge = parameters[USER_AGE] {
            Tune.setAge(Int(userAge as! String)!)
            logger.logParamSetWithSuccess(USER_AGE, value: userAge);
        }
        if let userEmail = parameters[USER_EMAIL] {
            Tune.setUserEmail(userEmail as! String);
            logger.logParamSetWithSuccess(USER_EMAIL, value: userEmail);
        }
        // this condition calls setGender() which set a TuneGender object from a String parameter
        if let userGender = parameters[USER_GENDER] {
            self.setGender(userGender as! String);
        }
    }

    /// Method used to create and fire an event to the Tune Console
    /// The only mandatory parameter is eventName which is a necessity to build the event
    /// Without this parameter, the event won't be built.
    /// After the creation of the event object, some attributes can be added through the eventBuilder
    /// method, using the map obtained from the gtm container.
    ///
    /// After the creation of the event object, some attributes can be added through the
    /// buildEvent:withParameters: method, using the NSDictionary obtained from the gtm container.
    ///
    /// - Parameters:
    ///   - eventName (String) : the name of the event (mandatory, unless eventId is set)
    ///   - eventCurrencyCode
    ///   - eventAdvertiserRefId
    ///   - eventContentId
    ///   - eventContentType
    ///   - eventSearchString
    ///   - eventAttribute1
    ///   - eventAttribute2
    ///   - eventAttribute3
    ///   - eventAttribute4
    ///   - eventAttribute5
    ///   - eventRating
    ///   - eventDate1
    ///   - eventDate2 : Date1 needs to be set
    ///   - eventRevenue
    ///   - eventItems
    ///   - eventLevel
    ///   - eventReceipt
    fileprivate func tagEvent(_ parameters: [AnyHashable: Any]) {

        var tuneEvent: TuneEvent!;
        var params = parameters;

        // block for the event creation part of this method.
        // Creates a tune event, and remove the eventName value from the dictionary
        if let eventName = params[EVENT_NAME] {
            tuneEvent = TuneEvent.init(name: eventName as! String);
            params.removeValue(forKey: EVENT_NAME);
            logger.logParamSetWithSuccess(EVENT_NAME, value: eventName);
        }
        else {
            logger.logMissingParam(EVENT_NAME, methodName: TUN_TAG_EVENT);
            return ;
        }

        // call on the buildEvent whether the dictionary contains optional parameters
        if (params.count > 0 && (tuneEvent) != nil) {
            tuneEvent = buildEvent(tuneEvent, parameters: params);
        }
        
        // if the TuneEvent object isn't nil, the tag is sent. Otherwise, an error is displayed
        if (tuneEvent != nil) {
            Tune.measure(tuneEvent);
        }
        else {
            logger.carLog(kTAGLoggerLogLevelError,
                                message: "The Tune event is nil, the tag hasn't been sent.");
        }
    }


/* ****************************************** Utility ******************************************* */
    
    /// The method is used to add attributes to the event given as a parameter. The dictionary contains
    /// the key of the attributes to attach to this event. For the name of the key you have to give,
    /// please have a look at all the EVENT_... constants on the top of this file. The NSString Array
    /// contains all the parameters requested as NSString from Tune SDK, reflection is used to call the
    /// corresponding instance methods.
    ///
    /// - Parameters:
    ///   - tuneEvent: the event you want to custom
    ///   - parameters: the key/value list of the attributes you want to attach to your event
    /// - Returns: the custom event
    fileprivate func buildEvent(_ event: TuneEvent, parameters: [AnyHashable: Any]) -> TuneEvent {
        var params = parameters;
        var tuneEvent = event;

        // set different properties of the TuneEvent object,
        // if they exist in the parameters dictionary
        tuneEvent = setMixedPropertiesToEvent(tuneEvent: tuneEvent, params: parameters);
        for key: String in EVENT_MIXED_PROPERTIES {
            params.removeValue(forKey: key);
        }

        // set all the String typed properties of TuneEvent,
        // if they exist in the parameters dictionary.
        for property: String in EVENT_STRING_PROPERTIES {

            if let value = params[property] {
                var propertyName = (property as NSString).substring(from: 5);
                let firstChar = (propertyName as NSString).substring(to: 1);
                propertyName = firstChar.lowercased() + (propertyName as NSString).substring(from: 1);

                tuneEvent.setValue(value, forKey: propertyName);
                logger.logParamSetWithSuccess(property, value: value);
                params.removeValue(forKey: property);
            }
        }

        // print logs for the parameters which don't match any TuneEvent property
        for (key, _) in params {
            logger.logUnknownParam(key as! String);
        }

        return tuneEvent;
    }

    
    /// Sets all the properties of the TuneEvent object which are not String typed.
    ///
    /// - Parameters:
    ///   - tuneEvent: The TuneEvent object you want to set properties to.
    ///   - params: The list of parameters given through GTM callback.
    /// - Returns: The TuneEvent object with its attributes set to the correct values.
    fileprivate func setMixedPropertiesToEvent(tuneEvent: TuneEvent, params:[AnyHashable: Any]) -> (TuneEvent) {
        if let eventRating = params[EVENT_RATING] {
            if let n = NumberFormatter().number(from: eventRating as! String) {
                let f = CGFloat(n)
                tuneEvent.rating = f;
                logger.logParamSetWithSuccess(EVENT_RATING, value: tuneEvent.rating);
            }
            else {
                logger.logUncastableParam(EVENT_RATING, type: "CGFloat");
            }
        }
        if let eventDate1 = params[EVENT_DATE1] {
            let date1 = NSDate(timeIntervalSince1970: Double(eventDate1 as! String)!);
            tuneEvent.date1 = date1 as Date;
            logger.logParamSetWithSuccess(EVENT_DATE1, value: tuneEvent.date1);
            
            if let eventDate2 = params[EVENT_DATE2] {
                let date2 = NSDate(timeIntervalSince1970: Double(eventDate2 as! String)!);
                tuneEvent.date2 = date2 as Date;
                logger.logParamSetWithSuccess(EVENT_DATE2, value: tuneEvent.date2);
            }
        }
        if let eventRevenue = params[EVENT_REVENUE] {
            if let n = NumberFormatter().number(from: eventRevenue as! String) {
                let f = CGFloat(n)
                tuneEvent.revenue = f;
                logger.logParamSetWithSuccess(EVENT_REVENUE, value: tuneEvent.revenue);
            }
            else {
                logger.logUncastableParam(EVENT_REVENUE, type: "CGFloat");
            }
        }
        if let eventItems = params[EVENT_ITEMS] {
            if let tuneEventItems = self.getItems(flatJson: eventItems as! String) {
                tuneEvent.eventItems = tuneEventItems;
                logger.logParamSetWithSuccess(EVENT_ITEMS, value: tuneEvent.eventItems);
            }
            else {
                logger.logUncastableParam(EVENT_ITEMS, type: "[TuneEventItem]");
            }
        }
        if let eventLevel = params[EVENT_LEVEL] {
            tuneEvent.level = Int(eventLevel as! String)!;
            logger.logParamSetWithSuccess(EVENT_LEVEL, value: tuneEvent.level);
        }
        if let eventTransaction = params[EVENT_TRANSACTION_STATE] {
            tuneEvent.transactionState = Int(eventTransaction as! String)!;
            logger.logParamSetWithSuccess(EVENT_TRANSACTION_STATE, value: tuneEvent.transactionState);
        }
        if let eventReceipt = params[EVENT_RECEIPT] {
            if let data = (eventReceipt as! String).data(using: .utf8) {
                tuneEvent.receipt = data;
                logger.logParamSetWithSuccess(EVENT_RECEIPT, value: tuneEvent.receipt);
            }
            else {
                logger.logUncastableParam(EVENT_RECEIPT, type: "Data");
            }
        }
        if let eventQuantity = params[EVENT_QUANTITY] {
            let qty = Int(eventQuantity as! String)!;
            if (qty >= 0) {
                tuneEvent.quantity = UInt(qty);
                logger.logParamSetWithSuccess(EVENT_QUANTITY, value: tuneEvent.quantity);
            }
            else {
                tuneEvent.quantity = 0;
                logger.carLog(kTAGLoggerLogLevelWarning, message: "\(EVENT_QUANTITY) value has been" +
                    "set to 0 since the negative values are not accepted.");
            }
        }
        return tuneEvent;
    }
    
    /// A simple method called by identify() to set the Tune gender through a secured way
    ///
    /// - Parameter gender: The gender given in the identify method. If the gender doesn't match any
    ///                     Tune genders, sets the gender to UNKNOWN.
    fileprivate func setGender(_ gender: String) {
        let upperGender = gender.uppercased();
        if (upperGender == "MALE") {
            Tune.setGender(TuneGender.male);
            self.logger.logParamSetWithSuccess(USER_GENDER, value: "MALE");
        }
        else if (upperGender == "FEMALE") {
            Tune.setGender(TuneGender.female);
            self.logger.logParamSetWithSuccess(USER_GENDER, value: "FEMALE");
        }
        else {
            Tune.setGender(TuneGender.unknown);
            self.logger.logParamSetWithSuccess(USER_GENDER, value: "UNKNOWN");
        }
    }

    
    /// Retrieves an array of TuneEventItem from a simple String parameter.
    /// Makes the String a json object, type it to an array of dictionaries<String, AnyHashable>,
    /// then retrieves the correct values and set them into the correct object type.
    ///
    /// - Parameter flatJson: the String containing the json
    /// - Returns: a TuneEventItem array
    fileprivate func getItems(flatJson: String) -> ([TuneEventItem]?) {
        var tuneItemArray: [TuneEventItem] = [];

        // convert the String to Data type
        if let jsonData = flatJson.data(using: .utf8) {
            // retrieve the json from data
            let json = try? JSONSerialization.jsonObject(with: jsonData);
            // type the json format to an actual array of dictionaries
            if let dictFromJSON = json as? [Dictionary<String, AnyHashable>] {
                // iterates on dictionaries to create TuneEventItem objects which are added in an array
                for item in dictFromJSON {
                    if let name = item["name"],
                        let unitPrice = item["unitPrice"],
                        let quantity = item["quantity"], let revenue = item["revenue"] {

                        let tuneItem = TuneEventItem(name: name as! String,
                                                     unitPrice: revenue as! CGFloat,
                                                     quantity: quantity as! UInt,
                                                     revenue: unitPrice as! CGFloat);
                        if let attr1 = item["attribute1"] {
                            tuneItem?.attribute1 = attr1 as! String;
                        }
                        if let attr2 = item["attribute2"] {
                            tuneItem?.attribute2 = attr2 as! String;
                        }
                        if let attr3 = item["attribute3"] {
                            tuneItem?.attribute3 = attr3 as! String;
                        }
                        if let attr4 = item["attribute4"] {
                            tuneItem?.attribute4 = attr4 as! String;
                        }
                        if let attr5 = item["attribut5"] {
                            tuneItem?.attribute5 = attr5 as! String;
                        }
                        // adds the TuneEventItem to the array
                        tuneItemArray.append(tuneItem!);
                    }
                    else {
                        logger.logMissingParam("CargoItem name", methodName: TUN_TAG_EVENT);
                        logger.logUncastableParam(EVENT_ITEMS, type: "TuneEventItem");
                    }
                }
                // returns the array
                return tuneItemArray;
            }
            else {
                logger.logUncastableParam("eventItems", type: "json");
            }
        }
        else {
            logger.logUncastableParam("eventItems", type: "Data");
        }

        return nil;
    }
}


