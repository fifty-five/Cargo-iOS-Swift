//
//  Cargo.swift
//  SwiftSampleApp
//
//  Created by Julien Gil on 24/08/16.
//  Copyright © 2016 fifty-five All rights reserved.
//

import Foundation


class Cargo: NSObject {
    
/* ********************************* Variables Declaration ********************************* */

    static let sharedHelper = Cargo();
    var launchOptions: [NSObject: AnyObject]?;
    var registeredTagHandlers = Dictionary<String, CARTagHandler>();
    var tagManager:TAGManager!;
    var container:TAGContainer!;
    var logger: CARLogger!;


/* ************************************* Initializer *************************************** */

    /**
     * Initialization of Cargo and of the logger
     *
     */
    private override init() {
        logger = CARLogger(aContext: "Cargo");
        super.init();
    }


/* ********************************* Methods declaration *********************************** */

    /**
     * Setup the tagManager and the GTM container as properties of Cargo
     * Setup the log level of Cargo Logger from the level of the tagManager logger
     *
     * @param tagManager    The tag manager
     * @param tagContainer  The GTM container
     */
    func initTagHandlerWithManager(tagManager:TAGManager, tagContainer:TAGContainer) {
        //GTM
        self.tagManager = tagManager;
        self.container = tagContainer;

        //Logger
        self.logger.level = self.tagManager.logger.logLevel();
        logger.carLog(kTAGLoggerLogLevelInfo, message: "Cargo initialization is done");
    }


    /**
     * Retrieves the handlers.json file, parse it and initialize the handlers declared in it.
     * This method has to be called after "initTagHandlerWithManager"
     * and before trying to register handlers
     *
     */
    func initHandlers() {
        var names = [String]();

        // Retrieves the file and its content
        if let path = NSBundle.mainBundle().pathForResource("handlers", ofType: "json") {
            if let handlersJSON = NSData(contentsOfFile: path) {

                // NSJSONSerialization gives us a JSON object
                // do/catch block is used because JSONObjectWithData:options: may throw an error
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(handlersJSON, options: .AllowFragments);

                    // Gets "handlers" from the JSON and try to cast it to an array of dictionaries
                    // For all these dictionaries we try to get the name value as a string
                    // If it works, this string is added to the String array "names"
                    if let handlers = json["handlers"] as? [[String: AnyObject]] {
                        for handler in handlers {
                            if let name = handler["name"] as? String {
                                names.append(name);
                            }
                        }
                    }
                }
                catch {
                    print("error serializing JSON: \(error)")
                }

                // check for the handlers which have been declared in the Podfile and initialize them
                if (names.contains("GoogleAnalytics")) {
                    _ = CARGoogleAnalyticsTagHandler();
                }
            }
        }
    }


    /**
     * Called by each handler to register itself
     * in the registeredTagHandlers variable.
     *
     * @param tagHandler    The tag handler
     * @param key           The key the handler is register with
     */
    func registerTagHandler(tagHandler: CARTagHandler, key:String) {
        registeredTagHandlers[key] = tagHandler;
    }


    /**
     * For each handler stored in the registeredTagHandlers variable,
     * validate the handler in order to register its GTM callback methods
     *
     */
    func registerHandlers(){
        for (key, handler) in registeredTagHandlers {
            handler.validate();

            if (handler.valid){
                self.container.registerFunctionCallTagHandler(handler, forTag: key);
            }

            logger.carLog(kTAGLoggerLogLevelInfo, message: "Function with key \(key) has been registered for \(handler.name)");
        }
    }

}
