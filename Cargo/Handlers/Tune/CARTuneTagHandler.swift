//
//  CARTuneTagHandler.swift
//  Cargo
//
//  Created by Julien Gil on 30/08/16.
//  Copyright © 2016 fifty-five All rights reserved.
//

import Foundation


import Foundation

class CARTuneTagHandler: CARTagHandler {

/* ********************************* Variables Declaration ********************************* */

    let Tune_init = "Tune_init";
    let Tune_session = "Tune_measureSession";
    let Tune_identify = "Tune_identify";
    let Tune_tagEvent = "Tune_tagEvent";
    let Tune_tagScreen = "Tune_tagScreen";

    // Those are used in the buildEvent method.
    let EVENT_RATING = "eventRating";
    let EVENT_DATE1 = "eventDate1";
    let EVENT_DATE2 = "eventDate2";
    let EVENT_REVENUE = "eventRevenue";
    let EVENT_ITEMS = "eventItems";
    let EVENT_LEVEL = "eventLevel";
    let EVENT_RECEIPT = "eventReceipt";
    let EVENT_QUANTITY = "eventQuantity";
    let EVENT_TRANSACTION_STATE = "eventTransactionState";
    let EVENT_PROPERTIES: [String] = ["eventCurrencyCode", "eventRefId", "eventContentId", "eventContentType", "eventSearchString", "eventAttribute1", "eventAttribute2", "eventAttribute3", "eventAttribute4", "eventAttribute5"];

/* ************************************* Initializer *************************************** */

    /**
     *  Initialize the handler
     */
    init() {
        super.init(key: "TUN", name: "Tune");

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
        case Tune_init:
            self.initialize(parameters);
            break ;
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
            noTagMatch(self, tagName: tagName);
        }
    }

    /**
     *  Is called to set the advertiser ID & conversion key
     *
     *  @param parameters   Dictionary of parameters which should contain the advertiser ID
     *                      and the conversion key for this account
     */
    func initialize(_ parameters: [AnyHashable: Any]) {
        if let advertiserId = parameters["advertiserId"], let conversionKey = parameters["conversionKey"] {
            Tune.initialize(withTuneAdvertiserId: advertiserId as! String, tuneConversionKey: conversionKey as! String);
            self.initialized = true;
        }
        else {
            cargo.logger.logMissingParam("advertiserId/conversionKey", methodName: Tune_init, handler: self);
        }
    }

/* ********************************** Specific methods ************************************* */

    /**
     * Use it in AppDelegate in the method "applicationDidBecomeActive"
     * Attribution will not function without the measureSession call included.
     */
    fileprivate func measureSession() {
        // check if the initialization has been done
        if (!self.initialized) {
            cargo.logger.logUninitializedFramework(self);
            return;
        }
        Tune.measureSession();
    }

    /**
     * Allows you to identify your user through several ways
     *
     * @param parameters    Dictionary of parameters used to set up
     *                      the user identity through several ways.
     */
    fileprivate func identify(_ parameters: [AnyHashable: Any]) {
        // check if the initialization has been done
        if (!self.initialized) {
            cargo.logger.logUninitializedFramework(self);
            return;
        }

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

    /**
     * Method used to create and fire an event to the Tune Console
     * The only mandatory parameter is EVENT_NAME which is a necessity to build the event
     * Without this parameter, the event won't be built.
     * After the creation of the event object, some attributes can be added through the eventBuilder
     * method, using the map obtained from the gtm container.
     *
     * @param map   the parameters given at the moment of the dataLayer.push(),
     *              passed through the GTM container and the execute method.
     *              The only parameter requested here is a name or an id for the event
     *              (EVENT_NAME or EVENT_ID)
     *
     *
     *              BUT ALSO
     *
     *
     * Method used to create and fire a screen view to the Tune Console
     * The mandatory parameters is SCREEN_NAME which is a necessity to build the tagScreen.
     * Actually, as no native tagScreen is given in the Tune SDK, we fire a custom event.
     *
     * After the creation of the event object, some attributes can be added through the
     * buildEvent:withParameters: method, using the NSDictionary obtained from the gtm container.
     * We recommend to use Attribute1/2 if you need more information about the screen.
     *
     * @param map   the parameters given at the moment of the dataLayer.push(),
     *              passed through the GTM container and the execute method.
     *              The only parameter requested here is a name for the screen
     *              (SCREEN_NAME)

     */
    fileprivate func tagEvent(_ parameters: [AnyHashable: Any]) {

        var tuneEvent: TuneEvent!;
        var params = parameters;

        // check if the initialization has been done
        if (!self.initialized) {
            cargo.logger.logUninitializedFramework(self);
            return;
        }

        if let eventName = params[EVENT_NAME] {
            tuneEvent = TuneEvent.init(name: eventName as! String);
            params.removeValue(forKey: EVENT_NAME);
            cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: eventName, handler: self);
        }
        else if let eventName = params[SCREEN_NAME] {
            tuneEvent = TuneEvent.init(name: eventName as! String);
            params.removeValue(forKey: SCREEN_NAME);
            cargo.logger.logParamSetWithSuccess(SCREEN_NAME, value: eventName, handler: self);
        }
        else {
            cargo.logger.logMissingParam("\(EVENT_NAME)/\(SCREEN_NAME)", methodName: "\(Tune_tagEvent)/\(Tune_tagScreen)", handler: self);
            return ;
        }

        // call on the buildEvent if the dictionary contains optional parameters
        if (params.count > 0 && (tuneEvent) != nil) {
            tuneEvent = buildEvent(tuneEvent, parameters: params);
        }
        else if (params.count > 0) {
            cargo.logger.carLog(kTAGLoggerLogLevelDebug, handler: self, message: "tuneEvent object is nil");
        }

        // if the TuneEvent object isn't nil, the tag is sent. Otherwise, an error is displayed
        if ((tuneEvent) != nil) {
            Tune.measure(tuneEvent);
        }
        else {
            cargo.logger.carLog(kTAGLoggerLogLevelError, handler: self, message: "The tagEvent is nil, the tag did not fire");
        }
    }

/* *********************************** Utility methods ************************************* */

    /**
     * The method is used to add attributes to the event given as a parameter. The dictionary contains
     * the key of the attributes to attach to this event. For the name of the key you have to give,
     * please have a look at all the EVENT_... constants on the top of this file. The NSString Array
     * contains all the parameters requested as NSString from Tune SDK, reflection is used to call the
     * corresponding instance methods.
     *
     * @param parameters    the key/value list of the attributes you want to attach to your event
     * @param tuneEvent     the event you want to custom
     * @return              the custom event
     */

    fileprivate func buildEvent(_ tuneEvent: TuneEvent, parameters: [AnyHashable: Any]) -> TuneEvent {

        var params = parameters;

        // set different properties of the TuneEvent object,
        // if they exist in the parameters dictionary
        if let eventRating = params[EVENT_RATING] {
            tuneEvent.rating = eventRating as! CGFloat;
            params.removeValue(forKey: EVENT_RATING);
            cargo.logger.logParamSetWithSuccess("event rating", value: tuneEvent.rating, handler: self);
        }
        if let eventDate1 = params[EVENT_DATE1] {
            tuneEvent.date1 = eventDate1 as! Date;
            params.removeValue(forKey: EVENT_DATE1);
            cargo.logger.logParamSetWithSuccess("event date1", value: tuneEvent.date1, handler: self);

            if let eventDate2 = params[EVENT_DATE2] {
                tuneEvent.date2 = eventDate2 as! Date;
                params.removeValue(forKey: EVENT_DATE2);
                cargo.logger.logParamSetWithSuccess("event date2", value: tuneEvent.date2, handler: self);
            }
        }
        if let eventRevenue = params[EVENT_REVENUE] {
            tuneEvent.revenue = eventRevenue as! CGFloat;
            params.removeValue(forKey: EVENT_REVENUE);
            cargo.logger.logParamSetWithSuccess("event revenue", value: tuneEvent.revenue, handler: self);
        }
        if let eventItems = params[EVENT_ITEMS] {
            tuneEvent.eventItems = eventItems as! [AnyObject];
            params.removeValue(forKey: EVENT_ITEMS);
            cargo.logger.logParamSetWithSuccess("event eventItems", value: tuneEvent.eventItems, handler: self);
        }
        if let eventLevel = params[EVENT_LEVEL] {
            tuneEvent.level = eventLevel as! Int;
            params.removeValue(forKey: EVENT_LEVEL);
            cargo.logger.logParamSetWithSuccess("event level", value: tuneEvent.level, handler: self);
        }
        if let eventTransaction = params[EVENT_TRANSACTION_STATE] {
            tuneEvent.transactionState = eventTransaction as! Int;
            params.removeValue(forKey: EVENT_TRANSACTION_STATE);
            cargo.logger.logParamSetWithSuccess("event transactionState", value: tuneEvent.transactionState, handler: self);
        }
        if let eventReceipt = params[EVENT_RECEIPT] {
            tuneEvent.receipt = eventReceipt as! Data;
            params.removeValue(forKey: EVENT_RECEIPT);
            cargo.logger.logParamSetWithSuccess("event receipt", value: tuneEvent.receipt, handler: self);
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
            cargo.logger.logParamSetWithSuccess("event quantity", value: tuneEvent.quantity, handler: self);
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
                cargo.logger.logParamSetWithSuccess(propertyName, value: tuneEvent.value(forKey: propertyName)!, handler: self);
            }
        }

        // print logs for the parameters which don't match any TuneEvent property
        for (key, _) in params {
            cargo.logger.logUnknownParam(self, paramName: key as! String);
        }

        return tuneEvent;
    }

    /**
     * A simple method called by identify() to set the gender in a secured way
     *
     * @param gender    The gender given in the identify method.
     *                  If the gender doesn't match with the Tune genders,
     *                  sets the gender to UNKNOWN.
     */
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


