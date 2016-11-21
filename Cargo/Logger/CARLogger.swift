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
    var level:TAGLoggerLogLevelType;

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
        self.level = kTAGLoggerLogLevelVerbose;
        self.formatter = DateFormatter();
        self.formatter.dateFormat = dateFormat;
        super.init();
    }

    /// Initialize the logger with the desired context
    ///
    /// - Parameter aContext: A string which represents the context for this logger instance
    init(aContext:String) {
        self.context = aContext;
        self.level = kTAGLoggerLogLevelVerbose;
        self.formatter = DateFormatter();
        self.formatter.dateFormat = dateFormat;
        super.init();
        refToSelf = self;
    }
    
    
/* *************************************** Loging methods *************************************** */

    /// Logs a message with the desired level of log. Instantiate the logger object if it was not.
    ///
    /// - Parameters:
    ///   - intentLevel: The level with which the message should be logged.
    ///   - message: The message which will be logged
    func carLog(_ intentLevel:TAGLoggerLogLevelType, message:String){
        let carLogSelf = refToSelf;
        if (carLogSelf == nil) {
            refToSelf = CARLogger();
        }

        if (refToSelf.levelEnabled(intentLevel)){
            print("\(formatter.string(from: Date()))\(refToSelf.context) [\(refToSelf.nameOfLevel(intentLevel))]:", message);
        }
    }

    /// Log a message with the appropriate handler context.
    ///
    /// - Parameters:
    ///   - intentLevel: The level in which the message should be recorded.
    ///   - handler: The handler the message comes from
    ///   - message: The message which will be logged
    func carLog(_ intentLevel:TAGLoggerLogLevelType, handler:CARTagHandler, message:String){
        let carLogSelf = refToSelf;
        if (carLogSelf == nil) {
            refToSelf = CARLogger();
        }

        if (refToSelf.levelEnabled(intentLevel)){
            print("\(formatter.string(from: Date()))\(refToSelf.context) [\(refToSelf.nameOfLevel(intentLevel))] - \(handler.name) :", message);
        }
    }

    /// This method logs a warning about a missing required parameter.
    ///
    /// - Parameters:
    ///   - paramName: The missing param name
    ///   - methodName: The method name
    ///   - handler: The handler the message comes from
    func logMissingParam(_ paramName:String, methodName:String, handler:CARTagHandler) {
        carLog(kTAGLoggerLogLevelWarning, message: "Parameter '\(paramName)' is required in method '\(methodName)' of '\(handler.name)' handler");
    }

    /// Logs a warning about an uncastable param.
    ///
    /// - Parameters:
    ///   - paramName: The parameter which can't be cast
    ///   - type: The type the parameter was tried to be casted to.
    func logUncastableParam(_ paramName:String, type:String) {
        carLog(kTAGLoggerLogLevelWarning, message: "param \(paramName) cannot be casted to \(type) ");
    }

    /// Logs a warning about an uninitialized framework
    func logUninitializedFramework() {
        carLog(kTAGLoggerLogLevelWarning, message: "You must initialize the framework before using it");
    }

    /// Logs a warning about an uninitialized framework with the handler context
    ///
    /// - Parameter handler: the handler which needs its framework to be initialized
    func logUninitializedFramework(_ handler: CARTagHandler) {
        carLog(kTAGLoggerLogLevelWarning, message: "You must initialize \(handler) before using it");
    }

    /// Logs a succesful parameter setting
    ///
    /// - Parameters:
    ///   - paramName: The parameter name
    ///   - value: The value the parameter has been set to
    func logParamSetWithSuccess(_ paramName: String, value: Any) {
        carLog(kTAGLoggerLogLevelInfo, message: "Parameter '\(paramName)' has been set to '\(value)' with success");
    }

    /// Logs a succesful parameter setting
    ///
    /// - Parameters:
    ///   - paramName: The parameter name
    ///   - value: The value the parameter has been set to
    ///   - handler: The handler the parameter has been set in
    func logParamSetWithSuccess(_ paramName: String, value: Any, handler: CARTagHandler) {
        carLog(kTAGLoggerLogLevelInfo, handler: handler, message: "Parameter '\(paramName)' has been set to '\(value)' with success");
    }

    /// Logs a warning about an unknown parameter.
    ///
    /// - Parameter paramName: The parameter which isn't recognized.
    func logUnknownParam(_ paramName:String) {
        carLog(kTAGLoggerLogLevelWarning, message: "Parameter '\(paramName)' is unknown");
    }

    /// Logs a warning about an unknown parameter with a handler context.
    ///
    /// - Parameters:
    ///   - handler: The handler context
    ///   - paramName: The parameter which isn't recognized.
    func logUnknownParam(_ handler: CARTagHandler, paramName:String) {
        carLog(kTAGLoggerLogLevelWarning, handler: handler, message: "Parameter '\(paramName)' is unknown");
    }

    /// Logs a warning about a value which doesn't fit among a predifined value set
    ///
    /// - Parameters:
    ///   - value: The unknown value
    ///   - key: The name of the parameter
    ///   - possibleValues: The possible values
    func logNotFoundValue(_ value: String, key: String, possibleValues: Array<Any>) {
        carLog(kTAGLoggerLogLevelWarning, message: "Value '\(value)' for key '\(key)' is not found among possible values \(possibleValues)");
    }



/* *********************************** Utilities methods *********************************** */

    
    /// Defines if a message has to be logged by comparing its log level to the log level the logger
    /// is using.
    ///
    /// - Parameter intentLevel: The level of the message which want to be logged.
    /// - Returns: A boolean value telling whether the message can (true) or cannot (false) be logged.
    func levelEnabled(_ intentLevel:TAGLoggerLogLevelType) -> Bool {
        return ((level != kTAGLoggerLogLevelNone) && (valueOf(intentLevel) >= valueOf(level)));
    }

    
    /// Method used to give each logLevelType an int value in order to make comparison easier.
    ///
    /// - Parameter logLevel: the log level
    /// - Returns: the log level associated int value
    func valueOf(_ logLevel:TAGLoggerLogLevelType) -> Int {
        var result: Int!;
        switch (logLevel) {
        case kTAGLoggerLogLevelVerbose:
            result = 0;
            break;
        case kTAGLoggerLogLevelDebug:
            result = 1;
            break;
        case kTAGLoggerLogLevelInfo:
            result = 2;
            break;
        case kTAGLoggerLogLevelWarning:
            result = 3;
            break;
        case kTAGLoggerLogLevelError:
            result = 4;
            break;
        default:
            result = 5;
            break;
        }
        return result;
    }

    
    /// Returns a string associated to the level of the log.
    ///
    /// - Parameter logingLevel: the log level
    /// - Returns: the String defining the log level
    func nameOfLevel(_ logingLevel:TAGLoggerLogLevelType) -> String {
        var result: String!;
        switch (logingLevel) {
            case kTAGLoggerLogLevelVerbose:
                result = "VERB";
                break;
            case kTAGLoggerLogLevelDebug:
                result = "DEBU";
                break;
            case kTAGLoggerLogLevelInfo:
                result = "INFO";
                break;
            case kTAGLoggerLogLevelWarning:
                result = "WARN";
                break;
            case kTAGLoggerLogLevelError:
                result = "ERRO";
                break;
            case kTAGLoggerLogLevelNone:
                result = "NONE";
                break;
            default:
                result = "UNKN";
                break;
        }
        return result;
    }

}
