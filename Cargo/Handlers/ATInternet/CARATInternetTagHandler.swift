//
//  CARATInternetTagHandler.swift
//  Cargo
//
//  Created by Julien Gil on 06/09/16.
//  Copyright © 2016 fifty-five All rights reserved.
//

import Foundation
import Tracker


/// The class which handles interactions with the AT Internet SDK
class CARATInternetTagHandler: CARTagHandler {

/* *********************************** Variables Declaration ************************************ */

    /** Constants used to define callbacks in the register and in the execute method */
    let AT_init = "AT_init";
    let AT_setConfig = "AT_setConfig";
    let AT_tagScreen = "AT_tagScreen";
    let AT_tagEvent = "AT_tagEvent";

    let TRACKER_NAME = "trackerName";
    let OVERRIDE = "override";
    let CHAPTER1 = "chapter1";
    let CHAPTER2 = "chapter2";
    let CHAPTER3 = "chapter3";
    let BASKET = "isBasketView";
    let ACTION = "action";

    /** The tracker of the AT Internet SDK which sends the events */
    var tracker: Tracker;
    var debug: Bool = false;


/* ************************************ Handler core methods ************************************ */

    /// Initialize the handler, sets the default tracker and register the callbacks to the container
    /// Call it in the AppDelegate after you retrieved the GTM container and initialized Cargo.
    init() {
        self.tracker = ATInternet.sharedInstance.defaultTracker;
        super.init(key: "AT", name: "AT Internet");
        if (self.cargo.logger.valueOf(self.cargo.logger.level) <= 0) {
            self.tracker.enableDebugger = true;
        }
        cargo.registerTagHandler(self, key: AT_init);
        cargo.registerTagHandler(self, key: AT_setConfig);
        cargo.registerTagHandler(self, key: AT_tagScreen);
        cargo.registerTagHandler(self, key: AT_tagEvent);
    }

    /// A callback method for the registered callbacks method name mentionned in the register method.
    ///
    /// - Parameters:
    ///   - tagName: The method name called through the container (defined in the GTM interface)
    ///   - parameters: Dictionary of parameters key-object used as a way to give parameters
    ///                 to the class method aimed here
    override func execute(_ tagName: String, parameters: [AnyHashable: Any]) {
        super.execute(tagName, parameters: parameters);

        // At first, checks if we want to initialize
        if (tagName == AT_init) {
            self.initialize(parameters);
        }
        // Else if the handler is initialized, looks for the right method to call
        else if (initialized == true) {
            switch (tagName) {
            case AT_setConfig:
                self.setConfig(parameters: parameters);
                break ;
            case AT_tagScreen:
                self.tagScreen(parameters: parameters);
                break ;
            case AT_tagEvent:
                self.tagEvent(parameters: parameters);
                break ;
            default:
                noTagMatch(self, tagName: tagName);
            }
        }
        // If it wasn't initialized, logs that the framework needs to be initialized
        else {
            cargo.logger.logUninitializedFramework(self);
        }
    }


/* ************************************* SDK initialization ************************************* */

    /// The method you have to call first, because it initializes
    /// the AT Internet tracker with the parameters you give.
    ///
    /// - Parameters:
    ///   - trackerName : if you want to use a particular tracker
    ///   - dictionary ([String: String]) : your setup for the tracker
    ///
    ///                               OR
    ///
    ///   - siteId : id you got when you register your app,
    ///              used to report hits to your AT interface
    func initialize(_ parameters: [AnyHashable: Any]) {
        var params = parameters;

        // check if a tracker name is set, then initialize the tracker with required values
        if let trackerName = params[TRACKER_NAME] {
            params.removeValue(forKey: TRACKER_NAME);
            if params["siteId"] != nil {
                // the handler is initialized once the siteId has been set
                self.initialized = true;
            }
            tracker = ATInternet.sharedInstance.tracker(trackerName as! String,
                                                        configuration:params as! [String : String]);
            cargo.logger.logParamSetWithSuccess(TRACKER_NAME, value: parameters);
        }
        // if the id is present, set up the tracker (async) and logs through a callback method
        else if let siteId = params["siteId"] {
            tracker.setConfig(TrackerConfigurationKeys.Site, value: siteId as! String,
                              completionHandler: { (isSet) -> Void in
                                self.cargo.logger.carLog(kTAGLoggerLogLevelInfo, handler: self,
                                                         message: "AT Internet siteId set to \(siteId)");
            });
            // the handler is initialized once the siteId has been set
            self.initialized = true;
        }
        else {
            cargo.logger.logMissingParam("siteId or \(TRACKER_NAME)", methodName: "initialize", handler: self);
        }
    }

    /// The method you may call if you want to reconfigure your tracker
    ///
    /// - Parameters:
    ///   - override (boolean) : if you want your values to override the existant data
    ///   - Dictionary ([String: String]) : your setup for the tracker
    func setConfig(parameters: [AnyHashable: Any]) {
        var params = parameters;

        if let override = params[OVERRIDE] {
            params.removeValue(forKey: OVERRIDE);

            // set up the tracker (async) and logs through a callback method
            tracker.setConfig(params as! [String : String], override: override as! Bool) { (isSet) -> Void in
                self.cargo.logger.carLog(kTAGLoggerLogLevelInfo, handler: self,
                                    message: "tracker reconfigured with \(params) and override set to \(override)");
            }
        }
    }


/* ****************************************** Tracking ****************************************** */

    /// Method used to create and fire a screen view to AT Internet
    /// The mandatory parameter is screenName
    ///
    /// - Parameters:
    ///   - screenName (String) : the name of the screen that has been seen
    ///   - chapter1 (String) : a custom dimension to set some more context
    ///   - chapter2 (String) : a second custom dim to set some more context
    ///   - chapter3 (String) : a third custom dim to set some more context
    ///   - level2 (int) : to add a second level to the screen
    ///   - isBasketView (bool) : set to true if the screen view is a basket one
    ///   - action (ScreenAction) : defines the action type
    func tagScreen(parameters: [AnyHashable: Any]) {

        // check for the mandatory parameter screenName
        if let screenName = parameters[SCREEN_NAME] {
            // create the screen object
            var screen = tracker.screens.add(screenName as! String);
            cargo.logger.logParamSetWithSuccess(SCREEN_NAME, value: screen.name);

            // check for optional parameters. returns object with these properties set if needed.
            screen = self.setAdditionalScreenProperties(parameters: parameters as [NSObject : AnyObject], screen: screen);

            // fire the hit
            screen.sendView();
        }
        else {
            cargo.logger.logMissingParam(SCREEN_NAME, methodName: "tagScreen", handler: self);
        }
    }

    /**
     * Method used to create and fire an event to the AT Internet interface
     * The mandatory parameters are eventName, eventType which are a necessity to build the event.
     * Without these parameters, the event won't be built.
     *
     * @param params    the parameters given at the moment of the dataLayer.push(),
     *                  passed through the GTM container and the execute method.
     *                  * eventName (String) : the name for this event.
     *                  * eventType (String) : defines the type of event you want to send.
     *                    the different values can be :     - sendTouch
     *                                                      - sendNavigation
     *                                                      - sendDownload
     *                                                      - sendExit
     *                                                      - sendSearch
     *                  * chapter1/2/3 (String) : used to add more context to the event
     *                  * level2 (int) : to add a second level to the event
     *                  * action (GestureAction) : defines the action type
     */
    
    /// Method used to create and fire an event to the AT Internet interface
    /// The mandatory parameters are eventName, eventType which are a necessity to build the event.
    /// Without these parameters, the event won't be built.
    ///
    /// - Parameters:
    ///   - eventName (String) : the name for this event.
    ///   - eventType (String) : defines the type of event you want to send.
    ///                    the different values can be : - sendTouch
    ///                                                  - sendNavigation
    ///                                                  - sendDownload
    ///                                                  - sendExit
    ///                                                  - sendSearch
    ///   - chapter1/2/3 (String) : used to add more context to the event
    ///   - level2 (int) : to add a second level to the event
    ///   - action (GestureAction) : defines the action type
    func tagEvent(parameters: [AnyHashable: Any]) {
        
        // check for the mandatory parameters eventName and eventType
        if let eventName = parameters[EVENT_NAME], let eventType = parameters[EVENT_TYPE] {
            // create the event object
            var event = tracker.gestures.add(eventName as! String);
            cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: event.name);
            
            // check for optional parameters. returns object with these properties set if needed.
            event = self.setAdditionalEventProperties(parameters: parameters as [NSObject : AnyObject], event: event);
            
            // fire a hit with the requested type
            switch eventType as! String {
                case "sendTouch":
                    event.sendTouch();
                case "sendNavigation":
                    event.sendNavigation();
                case "sendDownload":
                    event.sendDownload();
                case "sendExit":
                    event.sendExit();
                case "sendSearch":
                    event.sendSearch();
                default:
                    cargo.logger.logNotFoundValue(eventType as! String, key: EVENT_TYPE,
                                                  possibleValues: ["sendTouch",
                                                                   "sendNavigation",
                                                                   "download",
                                                                   "sendExit",
                                                                   "sendSearch"]);
            }
        }
        else {
            cargo.logger.logMissingParam("\(EVENT_NAME) and/or \(EVENT_TYPE)", methodName: "tagEvent", handler: self);
        }
    }


/* ****************************************** Utility ******************************************* */

    /// A custom method which looks for additional paramters for the screen creation.
    /// If some optional parameters are found, set the correct property of the screen object.
    ///
    /// - Parameters:
    ///   - parameters: a dictionary of additional parameters
    ///   - screen: a screen object you want to set extra parameters to
    /// - Returns: the screen object with the parameters
    private func setAdditionalScreenProperties(parameters: [AnyHashable: Any], screen: Screen) -> Screen {
        let screen = screen;

        if let level2 = parameters[LEVEL2] {
            screen.level2 = level2 as! Int;
            cargo.logger.logParamSetWithSuccess(SCREEN_NAME, value: screen.name);
        }
        if let basket = parameters[BASKET] {
            screen.isBasketScreen = basket as! Bool;
            cargo.logger.logParamSetWithSuccess(BASKET, value: screen.isBasketScreen);
        }
        if let action = parameters[ACTION] {
            screen.action = action as! AbstractScreen.ScreenAction;
            cargo.logger.logParamSetWithSuccess(ACTION, value: screen.action);
        }
        
        if let chapter1 = parameters[CHAPTER1] {
            screen.chapter1 = chapter1 as? String;
            cargo.logger.logParamSetWithSuccess(CHAPTER1, value: screen.chapter1!);
            
            if let chapter2 = parameters[CHAPTER2] {
                screen.chapter2 = chapter2 as? String;
                cargo.logger.logParamSetWithSuccess(CHAPTER2, value: screen.chapter2!);
                
                if let chapter3 = parameters[CHAPTER3] {
                    screen.chapter3 = chapter3 as? String;
                    cargo.logger.logParamSetWithSuccess(CHAPTER3, value: screen.chapter3!);
                }
            }
        }

        return screen;
    }

    /// A custom method which looks for additional parmaters for the event creation.
    /// If some optional parameters are found, set the correct property of the event object.
    ///
    /// - Parameters:
    ///   - parameters: a dictionary of additional parameters
    ///   - event: an event object you want to set extra parameters to
    /// - Returns: the event object with the parameters
    private func setAdditionalEventProperties(parameters: [AnyHashable: Any], event: Gesture) -> Gesture {
        let event = event;
        
        if let level2 = parameters[LEVEL2] {
            event.level2 = level2 as! Int;
            cargo.logger.logParamSetWithSuccess(SCREEN_NAME, value: event.name);
        }
        if let action = parameters[ACTION] {
            event.action = action as! Gesture.GestureAction;
            cargo.logger.logParamSetWithSuccess(ACTION, value: event.action);
        }

        if let chapter1 = parameters[CHAPTER1] {
            event.chapter1 = chapter1 as? String;
            cargo.logger.logParamSetWithSuccess(CHAPTER1, value: event.chapter1!);

            if let chapter2 = parameters[CHAPTER2] {
                event.chapter2 = chapter2 as? String;
                cargo.logger.logParamSetWithSuccess(CHAPTER2, value: event.chapter2!);

                if let chapter3 = parameters[CHAPTER3] {
                    event.chapter3 = chapter3 as? String;
                    cargo.logger.logParamSetWithSuccess(CHAPTER3, value: event.chapter3!);
                }
            }
        }
        return event;
    }

}
