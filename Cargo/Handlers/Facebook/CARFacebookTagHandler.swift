//
//  CARFacebookTagHandler.swift
//  Cargo
//
//  Created by François K on 06/09/2016.
//  Copyright © 2016 55 SAS. All rights reserved.
//

import Foundation
import FacebookCore


class CARFacebookTagHandler: CARTagHandler {

/* ********************************* Variables Declaration ********************************* */
    
    let FB_initialize = "FB_initialize";
    let FB_activateApp = "FB_activateApp";
    let FB_tagEvent = "FB_tagEvent";
    let FB_purchase = "FB_purchase";

/* ************************************* Initializer *************************************** */
    
    /**
     *  Initialize the handler
     */
    init() {
        super.init(key: "FB", name: "Facebook");
        
        cargo.registerTagHandler(self, key: FB_initialize);
        cargo.registerTagHandler(self, key: FB_activateApp);
        cargo.registerTagHandler(self, key: FB_tagEvent);
        cargo.registerTagHandler(self, key: FB_purchase);
    }


/* ******************************** Core handler methods *********************************** */

    /**
     *  Call back from GTM container to execute a specific action
     *  after tag and parameters are received
     *
     *  @param tagName  The tag name
     *  @param parameters   Dictionary of parameters
     */
    override func execute(_ tagName: String, parameters: [AnyHashable: Any]){
        super.execute(tagName, parameters: parameters);
        
        switch (tagName) {
        case FB_initialize:
            self.initialize(parameters: parameters);
            break ;
        case FB_activateApp:
            self.activateApp();
            break ;
        case FB_tagEvent:
            self.tagEvent(parameters: parameters);
            break ;
        case FB_purchase:
            self.purchase(parameters: parameters);
            break ;
        default:
            noTagMatch(self, tagName: tagName);
        }
    }

    /**
     *  Initialize Facebook SDK with the Application id given by Facebook when Facebook app has benn created
     */
    func initialize(parameters: [AnyHashable: Any]){
        if let applicationId = parameters["applicationId"]{
            AppEventsLogger.loggingAppId = applicationId as? String;
            cargo.logger.logParamSetWithSuccess("applicationId", value: applicationId, handler: self);
        }
        self.activateApp()
    }

    /**
     * Activate events logging
     */
    func activateApp(){
        AppEventsLogger.activate(UIApplication.shared);
        cargo.logger.carLog(kTAGLoggerLogLevelInfo, handler: self, message: "Facebook activateApp sent.");
    }


/* ********************************** Specific methods ************************************* */

    /**
     *  Send an event to facebook SDK. Calls differents methods depending on which parameters have been given
     *  Each events can be logged with a valueToSum and a set of parameters (up to 25 parameters).
     *  When reported, all of the valueToSum properties will be summed together. It is an arbitrary number
     *  that can represent any value (e.g., a price or a quantity).
     *
     *  @param valueToSum   The value to sum
     *  @param parameters   Dictionary of parameters
     *  Note that both the valueToSum and parameters arguments are optional.
     */
    func tagEvent(parameters: [AnyHashable: Any]){
        var params = parameters;

        if let eventName = params[EVENT_NAME] {
            params.removeValue(forKey: EVENT_NAME as NSObject);

            if let valueToSum = params["valueToSum"]{
                params.removeValue(forKey: "valueToSum" as NSObject);

                if(params.count>0){
                    AppEventsLogger.log(eventName as!String, parameters: params as! AppEvent.ParametersDictionary, valueToSum: valueToSum as? Double);
                    cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: eventName, handler: self);
                    cargo.logger.logParamSetWithSuccess("valueToSum", value: valueToSum, handler: self);
                    cargo.logger.logParamSetWithSuccess("params", value: params, handler: self);
                }
                else{
                    AppEventsLogger.log(eventName as! String, valueToSum: valueToSum as? Double);
                    cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: eventName, handler: self);
                    cargo.logger.logParamSetWithSuccess("valueToSum", value: valueToSum, handler: self);
                }
            }
            else{
                if(params.count>0){
                    AppEventsLogger.log(eventName as! String, parameters: params as! AppEvent.ParametersDictionary);
                    cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: eventName, handler: self);
                    cargo.logger.logParamSetWithSuccess("params", value: params, handler: self);
                }
                else{
                    AppEventsLogger.log(eventName as! String);
                    cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: eventName, handler: self);
                }
            }
        }
    }

    /*
     *  Logs a purchase in your app. with purchaseAmount the money spent, and currencyCode the currency code.
     *  The currency specification is expected to be an ISO 4217 currency code.
     *
     *  @param purchaseAmount  the amount of the purchase (mandatory)
     *  @param currency code  the currency of the purchase (mandatory)
     
     *  @param parameters   Dictionary of parameters
     */
    func purchase(parameters: [AnyHashable: Any]){
        if let purchaseAmount = parameters["purchaseAmount"] as? Double, let currencyCode = parameters["currencyCode"] as? String {
            AppEventsLogger.log(.purchased(amount: purchaseAmount, currency: currencyCode));
            cargo.logger.logParamSetWithSuccess("purchaseAmount", value: purchaseAmount, handler: self);
            cargo.logger.logParamSetWithSuccess("currencyCode", value: currencyCode, handler: self);
        }
        else {
            cargo.logger.logMissingParam("purchaseAmount AND/OR currencyCode", methodName: "purchase", handler: self);
        }
    }
}
