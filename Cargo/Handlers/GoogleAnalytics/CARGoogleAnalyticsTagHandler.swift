//
//  CARGoogleAnalyticsTagHandler.swift
//  Cargo
//
//  Created by Julien Gil on 24/08/16.
//  Copyright © 2016 fifty-five All rights reserved.
//

import Foundation

class CARGoogleAnalyticsTagHandler: CARTagHandler {

/* ********************************* Variables Declaration ********************************* */

    var tracker: GAITracker!;
    var instance: GAI!;


    let GA_init = "GA_init";
    let GA_set = "GA_set";
    let GA_setUserId = "GA_setUserId";
    let GA_tagScreen = "GA_tagScreen";
    let GA_tagEvent = "GA_tagEvent";

/* ************************************* Initializer *************************************** */

    /**
     *  Initialize the handler
     */
    init() {
        super.init(key: "GA", name: "Google Analytics");
        self.GA_configuration();
        self.instance = GAI.sharedInstance();
        self.tracker = self.instance.defaultTracker;

        cargo.registerTagHandler(self, key: GA_init);
        cargo.registerTagHandler(self, key: GA_set);
        cargo.registerTagHandler(self, key: GA_setUserId);
        cargo.registerTagHandler(self, key: GA_tagScreen);
        cargo.registerTagHandler(self, key: GA_tagEvent);
    }

    /**
     *  Mandatory to use GA, configures the tracker from the plist file
     */
    func GA_configuration(){
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?;
        GGLContext.sharedInstance().configureWithError(&configureError);
        assert(configureError == nil, "Error configuring Google services: \(configureError)");

        // Optional: configure GAI options.
        let gai = GAI.sharedInstance();
        gai?.trackUncaughtExceptions = true;  // report uncaught exceptions
        switch (cargo.logger.level) {
        case kTAGLoggerLogLevelNone:
            gai?.logger.logLevel = GAILogLevel.none;
            break ;
        case kTAGLoggerLogLevelInfo:
            gai?.logger.logLevel = GAILogLevel.info;
            break ;
        case kTAGLoggerLogLevelWarning:
            gai?.logger.logLevel = GAILogLevel.warning;
            break ;
        case kTAGLoggerLogLevelDebug:
            gai?.logger.logLevel = GAILogLevel.warning;
            break ;
        case kTAGLoggerLogLevelVerbose:
            gai?.logger.logLevel = GAILogLevel.verbose;
            break ;
        default:
            gai?.logger.logLevel = GAILogLevel.error;
        }
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
        case GA_init:
            self.initialize(parameters);
            break ;
        case GA_set:
            self.set(parameters);
            break ;
        case GA_setUserId:
            self.setUserId(parameters);
            break ;
        case GA_tagEvent:
            self.tagEvent(parameters);
            break ;
        case GA_tagScreen:
            self.tagScreen(parameters);
            break ;
        default:
            noTagMatch(self, tagName: tagName);
        }
    }

    /**
     *  Is called to set the tracking ID
     *
     *  @param parameters   Dictionary of parameters which should contain the tracking ID
     */
    func initialize(_ parameters: [AnyHashable: Any]) {
        if let trackingId = parameters["trackingId"] {
            self.tracker = self.instance.tracker(withTrackingId: trackingId as! String);
            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "tracking ID set to \(trackingId)");
        }
        else {
            cargo.logger.logMissingParam("trackingId", methodName: "GA_init", handler: self);
        }
    }

    /**
     *  Called to set optional parameters
     *
     *  @param parameters   Dictionary of parameters
     */
    func set(_ parameters: [AnyHashable: Any]) {

        if let trackUnCaughtException = parameters["trackUncaughtExceptions"] {
            self.instance.trackUncaughtExceptions = trackUnCaughtException as! Bool;
            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "trackUnCaughtException set as \(trackUnCaughtException)");
        }
        if let allowIdfaCollection = parameters["allowIdfaCollection"] {
            self.tracker.allowIDFACollection = allowIdfaCollection as! Bool;
            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "allowIdfaCollection set as \(allowIdfaCollection)");
        }
        if let dispatchInterval = parameters["dispatchInterval"] {
            self.instance.dispatchInterval = dispatchInterval as! TimeInterval;
            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "dispatchInterval set as \(dispatchInterval)");
        }
    }

/* ********************************** Specific methods ************************************* */

    /**
     * Used to setup the userId when the user logs in
     *
     * @param parameters    dictionary of parameters
     *                      * requires a userId parameter
     */
    func setUserId(_ parameters: [AnyHashable: Any]){

        if let userID = parameters[USER_ID] {
            self.tracker.set(kGAIUserId, value: userID as! String);
        }
        else {
            cargo.logger.logMissingParam(USER_ID, methodName: "GA_setUserId", handler: self);
        }
    }

    /**
     *  Used to send a screen event to Google Analytics
     *
     *  @param parameters   Dictionary of parameters
     *                      * requires a screenName value (String)
     */
    func tagScreen(_ parameters: [AnyHashable: Any]) {

        if let screenName = parameters[SCREEN_NAME] {
            self.tracker.set(kGAIScreenName, value: screenName as! String);
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build();
            self.tracker.send(builder as! [NSObject : AnyObject]);
        }
        else {
            cargo.logger.logMissingParam(SCREEN_NAME, methodName: "GA_tagScreen", handler: self);
        }
    }

    /**
     *  Used to send an event to Google Analytics
     *
     *  @param parameters   Dictionary of parameters
     *                      * requires an eventCategory value (String)
     *                      * requires an eventAction value (String)
     *                      * optional value of label (String)
     *                      * optional value of value (NSNumber)
     */
    func tagEvent(_ parameters: [AnyHashable: Any]) {
        if let category = parameters["eventCategory"], let action = parameters["eventAction"] {
            let label = parameters["eventLabel"];
            let value = parameters["eventValue"];

            let builder: NSObject = GAIDictionaryBuilder.createEvent(withCategory: category as! String, action: action as! String, label: label as? String, value: value as? NSNumber).build();
            self.tracker.send(builder as! [NSObject : AnyObject]);
        }
        else if (parameters["eventCategory"] == nil) {
            cargo.logger.logMissingParam("eventCategory", methodName: "GA_tagEvent", handler: self);
        }
        else {
            cargo.logger.logMissingParam("eventAction", methodName: "GA_tagEvent", handler: self);
        }
    }

}
