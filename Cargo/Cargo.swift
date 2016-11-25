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

    /** A constant that hold the Cargo instance, which allow to use it as a singleton */
    static let sharedHelper = Cargo();
    /** The logger used to print logs in Cargo and its handlers */
    var logger: CARLogger!;
    /** A dictionary which registers a handler for a specific tag function call */
    var registeredTagHandlers = Dictionary<String, CARTagHandler>();
    
    /** The Google Tag Manager */
    var tagManager:TAGManager!;
    /** The container which contains tags, triggers and variables defined in the GTM interface */
    var container:TAGContainer!;
    /** Dictionary used to copy and store the launch options from the AppDelegate */
    var launchOptions: [AnyHashable: Any]?;


/* ************************************* Initializer *************************************** */

    /// Initialization of Cargo and of the logger.
    /// The method is private because Cargo has to be instantiate through the sharedHelper attribute.
    fileprivate override init() {
        logger = CARLogger(aContext: "Cargo");
        super.init();
    }


/* ********************************* Methods declaration *********************************** */

    /// Setup the tagManager and the GTM container as properties of Cargo
    /// Setup the log level of the Cargo logger from the level of the tagManager logger
    /// This method has to be called right after retrieving the Cargo instance for the first time,
    /// and before any other Cargo method.
    ///
    /// - Parameters:
    ///   - tagManager: The tag manager instance
    ///   - tagContainer: The GTM container instance
    func initTagHandlerWithManager(_ tagManager:TAGManager, tagContainer:TAGContainer) {
        // GTM
        self.tagManager = tagManager;
        self.container = tagContainer;

        // Logger
        self.logger.setLogLevel(self.tagManager.logger.logLevel());
        logger.carLog(kTAGLoggerLogLevelInfo, message: "Cargo initialization is done");
    }

    /// Called by each handler in their constructors to register their GTM functions callbacks.
    /// A specific function key is linked to a specific handler.
    ///
    /// - Parameters:
    ///   - tagHandler: the tag handler registering for this callback
    ///   - key: the name of the function which will be used in GTM interface
    func registerTagHandler(_ tagHandler: CARTagHandler, key:String) {
        registeredTagHandlers[key] = tagHandler;
    }

    /// For each key stored in the registeredTagHandlers Dictionary, calls on the key,
    /// check if the handler was correctly initialized, then registers its GTM callback methods
    /// to the container for this particular handler.
    func registerHandlers(){
        for (key, handler) in registeredTagHandlers {
            handler.validate();

            if (handler.valid){
                self.container.register(handler, forTag: key);
                logger.carLog(kTAGLoggerLogLevelInfo,
                              message: "Function with key \(key) has been registered for \(handler.name) handler.");
            }
            else {
                logger.carLog(kTAGLoggerLogLevelError,
                              message: "\(handler.name) handler seems to be invalid. Function with key \(key) hasn't been registered.");
            }

        }
    }

}
