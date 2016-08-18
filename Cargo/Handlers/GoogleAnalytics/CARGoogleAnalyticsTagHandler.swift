//
//  CARGoogleAnalyticsTagHandler.swift
//  Cargo
//
//  Created by Med on 17/08/16.
//  Copyright © 2016 François K. All rights reserved.
//

import Foundation

class CARGoogleAnalyticsTagHandler: CARTagHandler {

/* ********************************* Variables Declaration ********************************* */

    var tracker: GAITracker!;
    var instance: GAI!;


    let GA_init = "GA_init";
    let GA_set = "GA_set";
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
        gai.trackUncaughtExceptions = true;  // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.Error;  // remove before app release
    }

/* ******************************** Core handler methods *********************************** */

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
        case GA_init:
            self.initialize(parameters);
            break ;
        case GA_set:
            self.set(parameters);
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
    func initialize(parameters: [NSObject : AnyObject]) {
        if let trackingId = parameters["trackingId"] {
            self.instance.trackerWithTrackingId(trackingId as! String);
            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "tracking ID set as \(trackingId)");
        }
    }

    /**
     *  Called to set optional parameters
     *
     *  @param parameters   Dictionary of parameters
     */
    func set(parameters: [NSObject : AnyObject]) {

        if let trackUnCaughtException = parameters["trackUncaughtExceptions"] {
            self.instance.trackUncaughtExceptions = trackUnCaughtException as! Bool;
            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "trackUnCaughtException set as \(trackUnCaughtException)");
        }
        if let allowIdfaCollection = parameters["allowIdfaCollection"] {
            self.tracker.allowIDFACollection = allowIdfaCollection as! Bool;
            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "allowIdfaCollection set as \(allowIdfaCollection)");
        }
        if let dispatchInterval = parameters["dispatchInterval"] {
            self.instance.dispatchInterval = dispatchInterval as! NSTimeInterval;
            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "dispatchInterval set as \(dispatchInterval)");
        }
    }

/* ********************************** Specific methods ************************************* */

    /**
     *  Used to send a screen event to Google Analytics
     *
     *  @param parameters   Dictionary of parameters
     *                      * requires a screenName value (String)
     */
    func tagScreen(parameters: [NSObject : AnyObject]) {

        if let screenName = parameters[SCREEN_NAME] {
            self.tracker.set(kGAIScreenName, value: screenName as! String);
            let builder = GAIDictionaryBuilder.createScreenView();
            self.tracker.send(builder.build() as [NSObject : AnyObject]);

            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "tagScreen fired with name '\(screenName)'");
        }
        else {
            cargo.logger.logMissingParam(EVENT_NAME, methodName: "tagScreen", handler: self);
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
    func tagEvent(parameters: [NSObject : AnyObject]) {
        if let category = parameters["eventCategory"], let action = parameters["eventAction"] {
            let label = parameters["eventLabel"];
            let value = parameters["eventValue"];

            let builder = GAIDictionaryBuilder.createEventWithCategory(category as! String, action: action as! String, label: label as? String, value: value as? NSNumber);
            self.tracker.send(builder.build() as [NSObject : AnyObject]);

            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "tagEvent fired with parameters '\(parameters)'");
        }
        else if (parameters["eventCategory"] == nil) {
            cargo.logger.logMissingParam("eventCategory", methodName: "tagEvent", handler: self);
        }
        else {
            cargo.logger.logMissingParam("eventAction", methodName: "tagEvent", handler: self);
        }
    }

}
