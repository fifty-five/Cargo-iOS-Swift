//
//  CARFacebookTagHandler.swift
//  Cargo
//
//  Created by François K on 06/09/2016.
//  Copyright © 2016 55 SAS. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKCoreKit.FBSDKAppEvents


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
     *  Initialize Facebook SDK with the Application id given by Facebook when Facebook app has benn created
     */
    func initialize(parameters: [NSObject : AnyObject]){
        if let applicationId = parameters["applicationId"]{
            FBSDKAppEvents.setLoggingOverrideAppID(applicationId as! String);
            cargo.logger.logParamSetWithSuccess("applicationId", value: applicationId, handler: self);
        }
        self.activateApp()
    }
    
    /**
     * Activate events logging
     */
    func activateApp(){
        FBSDKAppEvents.activateApp();
        cargo.logger.logParamSetWithSuccess("Activation", value: "Events logging activation", handler: self);
    }
    
    /**
     *  Call back from GTM container to execute a specific action
     *  after tag and parameters are received
     *
     *  @param tagName  The tag name
     *  @param parameters   Dictionary of parameters
     */
    override func execute(tagName: String, parameters: [NSObject : AnyObject]) {
        super.execute(tagName, parameters: parameters);
        
        switch (tagName) {
        case FB_initialize:
            self.initialize(parameters);
            break ;
        case FB_activateApp:
            self.activateApp();
            break ;
        case FB_tagEvent:
            self.tagEvent(parameters);
            break ;
        case FB_purchase:
            self.purchase(parameters);
            break ;
        default:
            noTagMatch(self, tagName: tagName);
        }
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
    func tagEvent(parameters: [NSObject : AnyObject]){
        var params = parameters;
        
        if let eventName = params[EVENT_NAME] {
            params.removeValueForKey(EVENT_NAME);
            
            if let valueToSum:Double = params["valueToSum"] as! Double{
                params.removeValueForKey("valueToSum");
                
                if(params.count>0){
                    FBSDKAppEvents.logEvent(eventName as!String, valueToSum: valueToSum, parameters: params);
                    cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: eventName, handler: self);
                    cargo.logger.logParamSetWithSuccess("valueToSum", value: valueToSum, handler: self);
                    cargo.logger.logParamSetWithSuccess("params", value: params, handler: self);
                }
                else{
                    FBSDKAppEvents.logEvent(eventName as! String, valueToSum: valueToSum);
                    cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: eventName, handler: self);
                    cargo.logger.logParamSetWithSuccess("valueToSum", value: valueToSum, handler: self);
                }
            }
            else{
                if(params.count>0){
                    FBSDKAppEvents.logEvent(eventName as! String, parameters: params);
                    cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: eventName, handler: self);
                    cargo.logger.logParamSetWithSuccess("params", value: params, handler: self);
                }
                else{
                    FBSDKAppEvents.logEvent(eventName as! String);
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
    func purchase(parameters: [NSObject : AnyObject]) {
        if (parameters["purchaseAmount"] != nil) || (parameters["currencyCode"] != nil){
            let purchaseAmount = (parameters["purchaseAmount"] as? Double)!;
            let currencyCode = (parameters["currencyCode"] as? String)!;
            FBSDKAppEvents.logPurchase(purchaseAmount, currency: currencyCode);
            cargo.logger.logParamSetWithSuccess("purchaseAmount", value: purchaseAmount, handler: self);
            cargo.logger.logParamSetWithSuccess("currencyCode", value: currencyCode, handler: self);
        }
        else {
            cargo.logger.logMissingParam("purchaseAmount OR currencyCode", methodName: "purchase", handler: self);
        }
    }
}