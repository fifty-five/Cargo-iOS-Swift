//
//  CARFirebaseTagHandler.swift
//  Cargo
//
//  Created by François Khoury on 31/08/2016.
//  Copyright © 2016 fifty-five All rights reserved.
//

import Foundation
import Firebase

class CARFirebaseTagHandler: CARTagHandler {
    
    /* ********************************* Variables Declaration ********************************* */
    
    var FirebaseAnalyticsClass: FIRAnalytics!;
    var FirebaseAnalyticsConf: FIRAnalyticsConfiguration!;
    
    let Firebase_init = "Firebase_init";
    let Firebase_identify = "Firebase_identify";
    let Firebase_tagScreen = "Firebase_tagScreen";
    let Firebase_tagEvent = "Firebase_tagEvent";
    let enableCollection = "enableCollection";
    
    /* ************************************* Initializer *************************************** */
    
    /**
     *  Initialize the handler
     */
    init() {
        super.init(key: "Firebase", name: "Firebase");
        self.FirebaseAnalyticsClass = FIRAnalytics();
        self.FirebaseAnalyticsConf = FIRAnalyticsConfiguration();
        FIRApp.configure();
        
        cargo.registerTagHandler(self, key: Firebase_init);
        cargo.registerTagHandler(self, key: Firebase_identify);
        cargo.registerTagHandler(self, key: Firebase_tagScreen);
        cargo.registerTagHandler(self, key: Firebase_tagEvent);
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
        case Firebase_init:
            self.initialize(parameters);
            break ;
        case Firebase_identify:
            self.identify(parameters);
            break ;
        case Firebase_tagEvent:
            self.tagEvent(parameters);
            break ;
        case Firebase_tagScreen:
            self.tagEvent(parameters); //because tagscreen is considered as an event anf Firebase v3.5.2
            break ;
        default:
            noTagMatch(self, tagName: tagName);
        }
    }
    
    /**
     * The method you may call first if you want to disable the Firebase analytics collection
     * The parameter requested is a boolean true/false for collection enabled/disabled
     * This setting is persisted across app sessions. By default it is enabled.
     *
     *
     *  @param parameters   Dictionary of parameters which should contain the tracking ID
     */
    func initialize(_ parameters: [AnyHashable: Any]) {
        if let enabled = parameters[enableCollection]{
            FirebaseAnalyticsConf.setAnalyticsCollectionEnabled(enabled as! Bool);
            cargo.logger.logParamSetWithSuccess(enableCollection, value: enabled as! Bool);
        }
        else{
            cargo.logger.logMissingParam(enableCollection, methodName: "Firebase_initialize", handler: self);
        }
    }
    
    
    /* ********************************** Specific methods ************************************* */
    
    /**
     * Used to identify the user and to define the segments it belongs to
     *
     * @param parameters    dictionary of parameters
     *                      * requires a userId parameter
     */
    func identify(_ parameters: [AnyHashable: Any]){
        
        if let userID = parameters[USER_ID] {
            FIRAnalytics.setUserID(userID as? String);
            cargo.logger.logParamSetWithSuccess(USER_ID, value: (userID as? String)!);
        }
        else {
            cargo.logger.logMissingParam(USER_ID, methodName: "Firebase_identify", handler: self);
        }
        
        for (key, value) in parameters {
            FIRAnalytics.setUserPropertyString(value as? String, forName:key as! String);
            cargo.logger.logParamSetWithSuccess((key as? String)!, value: (value as? String)!);
        }
    }
    
    /**
     * Method used to create and fire an event to the Firebase Console
     * The mandatory parameters is EVENT_NAME which is a necessity to build the event
     * Without this parameter, the event won't be built.
     * After the creation of the event object, some attributes can be added,
     * using the dictionary obtained from the gtm container.
     *
     * For the format to apply to the name and the parameters, check http://tinyurl.com/j7ppm6b
     *
     * params map   the parameters given at the moment of the dataLayer.push(),
     *              passed through the GTM container and the execute method.
     *              * EVENT_NAME : the only parameter requested here
     */
    func tagEvent(_ parameters: [AnyHashable: Any]){
        var params = parameters;
        
        if let eventName = params[EVENT_NAME] {
            params.removeValue(forKey: EVENT_NAME);
            if (params.count > 0) {
                FIRAnalytics.logEvent(withName: eventName as! String, parameters: params as? [String : NSObject]);
                cargo.logger.logParamSetWithSuccess(eventName as! String, value: params);
            }
            else {
                FIRAnalytics.logEvent(withName: eventName as! String, parameters: nil);
                cargo.logger.logParamSetWithSuccess(eventName as!String, value: parameters);
            }
        }
        else{
            cargo.logger.logMissingParam(EVENT_NAME, methodName: "Firebase_tagEvent", handler: self);
        }
    }
    
}
