//
//  CARLogger.swift
//  Cargo
//
//  Created by Med on 12/08/16.
//  Copyright © 2016 François K. All rights reserved.
//

import Foundation

/// A class that provides a logger for Cargo
class CARLogger: NSObject {

/* ********************************* Variables Declaration ********************************* */

    /// The logging level
    var level:LogLevelType!;

    /// The name of the application the logger is used for
    var superContext = "Cargo";

    /// The framework name
    var context:String;

    /// Reference to the logger instance
    var refToSelf:CARLogger!;

    /// Date formatter in order to log with the date
    var formatter: DateFormatter!;

    /// The format used to print date in logs
    let dateFormat = "yyyy-MM-dd HH:mm:ss.SSS ";


/* ************************************* Initializers ************************************** */

    /// Initialize the logger without a context
    /// is used when a call on carLog is made before init.
    fileprivate override init() {
        self.context = "Cargo";
        self.formatter = DateFormatter();
        self.formatter.dateFormat = dateFormat;
        super.init();
        refToSelf = self;
        self.setLogLevel(.verbose);
    }

    /// Initialize the logger with the desired context
    ///
    /// - Parameter aContext: A string which represents the context for this logger instance
    init(aContext:String, logLevel: LogLevelType) {
        self.context = aContext;
        self.formatter = DateFormatter();
        self.formatter.dateFormat = dateFormat;
        super.init();
        refToSelf = self;
        self.setLogLevel(.verbose);
    }
    
    
/* *************************************** Loging methods *************************************** */

    /// Log a message with the appropriate handler context.
    ///
    /// - Parameters:
    ///   - intentLevel: The level in which the message should be recorded.
    ///   - message: The message which will be logged
    func carLog(_ intentLevel:LogLevelType, message:String){
        let carLogSelf = refToSelf;
        if (carLogSelf == nil) {
            refToSelf = CARLogger();
        }

        if (refToSelf.levelEnabled(intentLevel)){
            let date = "\(formatter.string(from: Date()))";
            let info = "\(superContext) - \(context) [\(refToSelf.nameOfLevel(intentLevel))]";

            print("\(date)\(info):", message);
        }
    }

    /// This method logs a warning about a missing required parameter.
    ///
    /// - Parameters:
    ///   - paramName: The missing param name
    ///   - methodName: The method name
    func logMissingParam(_ paramName:String, methodName:String) {
        carLog(.warning, message: "Parameter '\(paramName)' is required in method '\(methodName)'");
    }
    
    /// Logs a warning about an uninitialized framework
    func logUninitializedFramework() {
        carLog(.info, message: "You must initialize the framework before using it");
    }

    /// Logs a succesful parameter setting
    ///
    /// - Parameters:
    ///   - paramName: The parameter name
    ///   - value: The value the parameter has been set to
    func logParamSetWithSuccess(_ paramName: String, value: Any) {
        carLog(.verbose, message: "Parameter '\(paramName)' has been set to '\(value)' with success");
    }

    /// Logs a warning about a value which doesn't fit among a predifined value set
    ///
    /// - Parameters:
    ///   - value: The unknown value
    ///   - key: The name of the parameter
    ///   - possibleValues: The possible values
    func logNotFoundValue(_ value: String, key: String, possibleValues: Array<Any>) {
        carLog(.warning,
               message: "Value '\(value)' for key '\(key)' is not found among possible values \(possibleValues)");
    }

    /// Called when a handler "execute" method is called. Logs the method call and its parameters
    ///
    /// - Parameters:
    ///   - tagName: the tag name of the callback method
    ///   - parameters: the parameters sent to the method through a dictionary
    func logReceivedFunction(_ tagName: String, parameters: [String: Any]) {
        carLog(.info,
               message: "Received function \(tagName) with parameters \(parameters)");
    }

    /// Logs when a tag doesn't match a method
    ///
    /// - Parameters:
    ///   - tagName: The tag name which doesn't match
    func logUnknownFunctionTag(_ tagName: String) {
        carLog(.debug,
               message: "Unable to find a method matching the function tag [\(tagName)].");
    }

    /// Logs a warning about an uncastable param.
    ///
    /// - Parameters:
    ///   - paramName: The parameter which can't be cast
    ///   - type: The type the parameter was tried to be casted to.
    func logUncastableParam(_ paramName:String, type:String) {
        carLog(.error,
               message: "Parameter '\(paramName)' cannot be casted to \(type) ");
    }

    /// Logs a warning about an unknown parameter.
    ///
    /// - Parameter paramName: The parameter which isn't recognized.
    func logUnknownParam(_ paramName:String) {
        carLog(.warning, message: "Parameter '\(paramName)' is unknown");
    }



/* *********************************** Utilities methods *********************************** */

    /// Enum for the level of log
    enum LogLevelType: Int {
        case verbose = 0;
        case debug = 1;
        case info = 2;
        case warning = 3;
        case error = 4;
        case none = 5;
    }

    /// Setter for the log level
     func setLogLevel(_ intentLevel:LogLevelType) {
        self.level = intentLevel;
        if (intentLevel.rawValue == 0 && self.context == "Cargo") {
            let message = "Verbose Mode Enabled. Do not release with this enabled.";
            carLog(.info, message: message);
        }
    }
    
    /// Defines if a message has to be logged by comparing its log level to the log level the logger
    /// is using.
    ///
    /// - Parameter intentLevel: The level of the message which want to be logged.
    /// - Returns: A boolean value telling whether the message can (true) or cannot (false) be logged.
    func levelEnabled(_ intentLevel:LogLevelType) -> Bool {
        return ((level != .none) && (intentLevel.rawValue >= level.rawValue));
    }
    
    /// Returns a string associated to the level of the log.
    ///
    /// - Parameter logingLevel: the log level
    /// - Returns: the String defining the log level
    func nameOfLevel(_ logingLevel:LogLevelType) -> String {
        var result: String!;
        switch (logingLevel) {
            case .verbose:
                result = "VERB";
                break;
            case .debug:
                result = "DEBU";
                break;
            case .info:
                result = "INFO";
                break;
            case .warning:
                result = "WARN";
                break;
            case .error:
                result = "ERRO";
                break;
            case .none:
                result = "NONE";
                break;
        }
        return result;
    }
    
}
