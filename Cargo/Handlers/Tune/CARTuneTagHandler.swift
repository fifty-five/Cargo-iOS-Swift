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
    let TUN_TAG_SCREEN = "TUN_tagScreen";

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
    let EVENT_PROPERTIES: [String] = ["eventCurrencyCode", "eventRefId",
                                      "eventContentId", "eventContentType",
                                      "eventSearchString", "eventAttribute1",
                                      "eventAttribute2", "eventAttribute3",
                                      "eventAttribute4", "eventAttribute5"];

/* ************************************ Handler core methods ************************************ */

    /// Called to instantiate the handler with its key and name properties.
    /// Enable or disable the Tune debug mode, based on the log level activated in the Cargo logger
    /// Register the callbacks to the container. After a dataLayer.push(),
    /// these will trigger the execute method of this handler.
    init() {
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
        cargo.registerTagHandler(self, key: TUN_TAG_SCREEN);
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
                case TUN_TAG_SCREEN:
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
            logger.logMissingParam([ADVERTISER_ID, CONVERSION_KEY], methodName: TUN_INIT);
        }
    }

/* ****************************************** Tracking ****************************************** */

    /// Use it in AppDelegate in the method "applicationDidBecomeActive"
    /// Attribution will not function without the measureSession call included.
    fileprivate func measureSession() {
        Tune.measureSession();
        self.logger.carLog(kTAGLoggerLogLevelInfo, "Measure session hit has been sent.");
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
            Tune.setAge(userAge as! Int)
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
    ///
    /// This method is also used to create and fire a screen view to the Tune Console
    /// The mandatory parameters is screenName which is a necessity to build the tagScreen.
    /// Actually, as no native tagScreen is given in the Tune SDK, we fire a custom event.
    ///
    /// After the creation of the event object, some attributes can be added through the
    /// buildEvent:withParameters: method, using the NSDictionary obtained from the gtm container.
    /// We recommend to use Attribute1/2 if you need more information about the screen.
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
        // block for the screen creation part of this method.
        // Creates a tune event, and remove the screenName value from the dictionary
        else if let eventName = params[SCREEN_NAME] {
            tuneEvent = TuneEvent.init(name: eventName as! String);
            params.removeValue(forKey: SCREEN_NAME);
            logger.logParamSetWithSuccess(SCREEN_NAME, value: eventName);
        }
        else {
            logger.logMissingParam("\(EVENT_NAME) or \(SCREEN_NAME)", methodName: "\(TUN_TAG_EVENT) or \(TUN_TAG_SCREEN)");
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
    fileprivate func buildEvent(_ tuneEvent: TuneEvent, parameters: [AnyHashable: Any]) -> TuneEvent {

        var params = parameters;

        // set different properties of the TuneEvent object,
        // if they exist in the parameters dictionary
        if let eventRating = params[EVENT_RATING] {
            tuneEvent.rating = eventRating as! CGFloat;
            params.removeValue(forKey: EVENT_RATING);
            logger.logParamSetWithSuccess(EVENT_RATING, value: tuneEvent.rating);
        }
        if let eventDate1 = params[EVENT_DATE1] {
            tuneEvent.date1 = eventDate1 as! Date;
            params.removeValue(forKey: EVENT_DATE1);
            logger.logParamSetWithSuccess(EVENT_DATE1, value: tuneEvent.date1);

            if let eventDate2 = params[EVENT_DATE2] {
                tuneEvent.date2 = eventDate2 as! Date;
                params.removeValue(forKey: EVENT_DATE2);
                logger.logParamSetWithSuccess(EVENT_DATE2, value: tuneEvent.date2);
            }
        }
        if let eventRevenue = params[EVENT_REVENUE] {
            tuneEvent.revenue = eventRevenue as! CGFloat;
            params.removeValue(forKey: EVENT_REVENUE);
            logger.logParamSetWithSuccess(EVENT_REVENUE, value: tuneEvent.revenue);
        }
        if let eventItems = params[EVENT_ITEMS] {
            tuneEvent.eventItems = eventItems as! [AnyObject];
            params.removeValue(forKey: EVENT_ITEMS);
            logger.logParamSetWithSuccess(EVENT_ITEMS, value: tuneEvent.eventItems);
        }
        if let eventLevel = params[EVENT_LEVEL] {
            tuneEvent.level = eventLevel as! Int;
            params.removeValue(forKey: EVENT_LEVEL);
            logger.logParamSetWithSuccess(EVENT_LEVEL, value: tuneEvent.level);
        }
        if let eventTransaction = params[EVENT_TRANSACTION_STATE] {
            tuneEvent.transactionState = eventTransaction as! Int;
            params.removeValue(forKey: EVENT_TRANSACTION_STATE);
            logger.logParamSetWithSuccess(EVENT_TRANSACTION_STATE, value: tuneEvent.transactionState);
        }
        if let eventReceipt = params[EVENT_RECEIPT] {
            tuneEvent.receipt = eventReceipt as! Data;
            params.removeValue(forKey: EVENT_RECEIPT);
            logger.logParamSetWithSuccess(EVENT_RECEIPT, value: tuneEvent.receipt);
        }
        if let eventQuantity = params[EVENT_QUANTITY] {
            let qty = eventQuantity as! Int;
            if (qty >= 0) {
                tuneEvent.quantity = UInt(qty);
                logger.logParamSetWithSuccess(EVENT_QUANTITY, value: tuneEvent.quantity);
            }
            else {
                tuneEvent.quantity = 0;
                logger.carLog(kTAGLoggerLogLevelWarning, message: "\(EVENT_QUANTITY) value has been" +
                    "set to 0 since the negative values are not accepted.");
            }
            params.removeValue(forKey: EVENT_QUANTITY);
        }

        // set all the String typed properties of TuneEvent,
        // if they exist in the parameters dictionary.
        for property: String in EVENT_PROPERTIES {

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
        for (key, _) in params {Cargo/Handlers/Tune/CARTuneTagHandler.swift
            logger.logUnknownParam(key as! String);
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
}


