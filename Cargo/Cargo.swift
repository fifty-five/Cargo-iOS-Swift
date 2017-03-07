//
//  Cargo.swift
//  SwiftSampleApp
//
//  Created by Julien Gil on 24/08/16.
//  Copyright © 2016 fifty-five All rights reserved.
//

import Foundation


@objc class Cargo: NSObject {
    
/* ************************************ Variables Declaration *********************************** */

    /** A constant that hold the Cargo instance, which allow to use it as a singleton */
    static var instance: Cargo!;
    /** The logger used to print logs in Cargo and its handlers */
    var logger: CARLogger!;
    /** A dictionary which registers a handler for a specific tag function call */
    var registeredTagHandlers = Dictionary<String, CARTagHandler>();

    /** Declaration of a String constant */
    let HANDLER_METHOD = "handlerMethod";

    /** Dictionary used to copy and store the launch options from the AppDelegate */
    var launchOptions: [AnyHashable: Any]?;


/* **************************************** Initializer ***************************************** */

    /// Initialization of Cargo and its logger.
    /// This constructor is called by default when calling getInstance without a previous
    /// initialization. The logLevel is set to none by default.
    fileprivate override init() {
        logger = CARLogger(aContext: "Cargo", logLevel: .none);
        super.init();
    }

    /// The constructor to call before getInstance method if a level of log is wanted.
    ///
    /// - Parameter logLevel: the desired level of log
    init(logLevel:CARLogger.LogLevelType) {
        logger = CARLogger(aContext: "Cargo", logLevel: logLevel);
        super.init();
        Cargo.instance = self;
    }

    /// A call on this method will return a fresh new instance of cargo if none have been 
    /// created until now, or the previously created instance. If this call creates a new 
    /// instance of Cargo, the level of log for this one will be 'none'. Refer to the
    /// setLogLevel method if another log level is needed.
    ///
    /// - Returns: an instance of Cargo object.
    @objc static func getInstance() -> (Cargo) {
        if (instance == nil) {
            instance = Cargo();
        }
        return instance;
    }


/* ************************************ Methods declaration ************************************* */

    /// Called by each handler in their constructors to register themselves into Cargo.
    /// The handler is stored under its key attribute.
    /// Also initialize the logger attribute for the handler with the same log level as Cargo.
    ///
    /// - Parameters:
    ///   - tagHandler: the tag handler to register
    func registerHandler(_ tagHandler: CARTagHandler) {
        registeredTagHandlers[tagHandler.key] = tagHandler;
        tagHandler.logger = CARLogger(aContext: "\(tagHandler.key)_handler",
            logLevel: self.logger.level);
        self.logger.carLog(.debug,
                           message: "\(tagHandler.name) handler has been registered into Cargo");
    }

    /// Sets the level of log for Cargo and the registered handlers
    ///
    /// - Parameter level: the level of log which will be used.
    func setLogLevel(level: CARLogger.LogLevelType) {
        self.logger.setLogLevel(level);
        for (_, handler) in registeredTagHandlers {
            handler.logger.setLogLevel(level);
        }
    }

    /// Method called from the Tags class, which one handles GTM callbacks.
    /// Those are redirected to this method which read into the parameters to find the 
    /// handler key and call the method of the appropriate handler.
    ///
    /// - Parameter parameters:
    ///   - handlerMethod: the method aimed by this tag callback.
    ///   - parameters: the rest of the dictionary containing the handler's method parameters.
    @objc func execute(_ parameters: [AnyHashable: Any]) {
        var params = parameters;
        if let handlerMethod = params[HANDLER_METHOD] as? String {
            params.removeValue(forKey: HANDLER_METHOD);
            let handlerKey = handlerMethod.components(separatedBy: "_")[0];
            if (handlerKey.characters.count > 1 && handlerKey.characters.count < 4) {
                if let handler = registeredTagHandlers[handlerKey] {
                    handler.execute(handlerMethod, parameters: params);
                }
                else {
                    logger.carLog(.warning,
                                  message: "Unable to find any handler corresponding to the \(handlerKey) key.");
                }
            }
            else {
                logger.carLog(.warning,
                              message: "The format of the handler's method name \(handlerMethod) seems to be incorrect.");
            }
        }
        else {
            logger.carLog(.warning,
                          message: "Parameter '\(HANDLER_METHOD)' is required in method cargo.execute()");
        }
    }
}
