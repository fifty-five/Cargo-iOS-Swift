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
    let Tune_init = "Tune_init";
    let Tune_session = "Tune_measureSession";
    let Tune_identify = "Tune_identify";
    let Tune_tagEvent = "Tune_tagEvent";
    let Tune_tagScreen = "Tune_tagScreen";

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

        cargo.registerTagHandler(self, key: Tune_init);
        cargo.registerTagHandler(self, key: Tune_session);
        cargo.registerTagHandler(self, key: Tune_identify);
        cargo.registerTagHandler(self, key: Tune_tagEvent);
        cargo.registerTagHandler(self, key: Tune_tagScreen);
    }

    /// Callback from GTM container designed to execute a specific method
    /// from its tag and the parameters received.
    ///
    /// - Parameters:
    ///   - tagName: the tag name of the aimed method
    ///   - parameters: Dictionary of parameters
    override func execute(_ tagName: String, parameters: [AnyHashable: Any]) {
        super.execute(tagName, parameters: parameters);

        if (tagName == Tune_init) {
            self.initialize(parameters);
            return ;
        }
        // check whether the SDK has been initialized before calling any method
        else if (self.initialized) {
            switch (tagName) {
                case Tune_session:
                    self.measureSession();
                    break ;
                case Tune_identify:
                    self.identify(parameters);
                    break ;
                case Tune_tagEvent:
                    self.tagEvent(parameters);
                    break ;
                case Tune_tagScreen:
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
        if let advertiserId = parameters["advertiserId"], let conversionKey = parameters["conversionKey"] {
            Tune.initialize(withTuneAdvertiserId: advertiserId as! String,
                            tuneConversionKey: conversionKey as! String);
            // the SDK is now initialized
            self.initialized = true;
            logger.logParamSetWithSuccess("advertiserId", value: advertiserId);
            logger.logParamSetWithSuccess("conversionKey", value: conversionKey);
        }
        else {
            logger.logMissingParam("advertiserId/conversionKey", methodName: Tune_init);
        }
    }

/* ****************************************** Tracking ****************************************** */

    /// Use it in AppDelegate in the method "applicationDidBecomeActive"
    /// Attribution will not function without the measureSession call included.
    fileprivate func measureSession() {
        Tune.measureSession();
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
        }
        if let userFacebookId = parameters[USER_FACEBOOK_ID] {
            Tune.setFacebookUserId(userFacebookId as! String);
        }
        if let userGoogleId = parameters[USER_GOOGLE_ID] {
            Tune.setGoogleUserId(userGoogleId as! String);
        }
        if let userTwitterId = parameters[USER_TWITTER_ID] {
            Tune.setTwitterUserId(userTwitterId as! String);
        }
        if let userName = parameters[USER_NAME] {
            Tune.setUserName(userName as! String);
        }
        if let userAge = parameters[USER_AGE] {
            Tune.setAge(userAge as! Int)
        }
        if let userEmail = parameters[USER_EMAIL] {
            Tune.setUserEmail(userEmail as! String);
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
    ///   - eventId (int) : id linked to the event (mandatory, unless eventName is set)
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

        // check if the initialization has been done
        if (!self.initialized) {
            logger.logUninitializedFramework();
            return;
        }

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
            logger.logMissingParam("\(EVENT_NAME) or \(SCREEN_NAME)", methodName: "\(Tune_tagEvent) or \(Tune_tagScreen)");
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
                                message: "The Tune event is nil, the tag did not fire");
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
            logger.logParamSetWithSuccess("event rating", value: tuneEvent.rating);
        }
        if let eventDate1 = params[EVENT_DATE1] {
            tuneEvent.date1 = eventDate1 as! Date;
            params.removeValue(forKey: EVENT_DATE1);
            logger.logParamSetWithSuccess("event date1", value: tuneEvent.date1);

            if let eventDate2 = params[EVENT_DATE2] {
                tuneEvent.date2 = eventDate2 as! Date;
                params.removeValue(forKey: EVENT_DATE2);
                logger.logParamSetWithSuccess("event date2", value: tuneEvent.date2);
            }
        }
        if let eventRevenue = params[EVENT_REVENUE] {
            tuneEvent.revenue = eventRevenue as! CGFloat;
            params.removeValue(forKey: EVENT_REVENUE);
            logger.logParamSetWithSuccess("event revenue", value: tuneEvent.revenue);
        }
        if let eventItems = params[EVENT_ITEMS] {
            tuneEvent.eventItems = eventItems as! [AnyObject];
            params.removeValue(forKey: EVENT_ITEMS);
            logger.logParamSetWithSuccess("event eventItems", value: tuneEvent.eventItems);
        }
        if let eventLevel = params[EVENT_LEVEL] {
            tuneEvent.level = eventLevel as! Int;
            params.removeValue(forKey: EVENT_LEVEL);
            logger.logParamSetWithSuccess("event level", value: tuneEvent.level);
        }
        if let eventTransaction = params[EVENT_TRANSACTION_STATE] {
            tuneEvent.transactionState = eventTransaction as! Int;
            params.removeValue(forKey: EVENT_TRANSACTION_STATE);
            logger.logParamSetWithSuccess("event transactionState", value: tuneEvent.transactionState);
        }
        if let eventReceipt = params[EVENT_RECEIPT] {
            tuneEvent.receipt = eventReceipt as! Data;
            params.removeValue(forKey: EVENT_RECEIPT);
            logger.logParamSetWithSuccess("event receipt", value: tuneEvent.receipt);
        }
        if let eventQuantity = params[EVENT_QUANTITY] {
            let qty = eventQuantity as! Int;
            if (qty >= 0) {
                tuneEvent.quantity = UInt(qty);
            }
            else {
                tuneEvent.quantity = 0;
            }
            params.removeValue(forKey: EVENT_QUANTITY);
            logger.logParamSetWithSuccess("event quantity", value: tuneEvent.quantity);
        }

        // set all the String typed properties of TuneEvent,
        // if they exist in the parameters dictionary.
        for property: String in EVENT_PROPERTIES {

            if let value = params[property] {
                var propertyName = (property as NSString).substring(from: 5);
                let firstChar = (propertyName as NSString).substring(to: 1);
                propertyName = firstChar.lowercased() + (propertyName as NSString).substring(from: 1);

                tuneEvent.setValue(value, forKey: propertyName);
                params.removeValue(forKey: property);
                logger.logParamSetWithSuccess(propertyName, value: tuneEvent.value(forKey: propertyName)!);
            }
        }

        // print logs for the parameters which don't match any TuneEvent property
        for (key, _) in params {
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
        }
        else if (upperGender == "FEMALE") {
            Tune.setGender(TuneGender.female);
        }
        else {
            Tune.setGender(TuneGender.unknown);
        }
    }
}


