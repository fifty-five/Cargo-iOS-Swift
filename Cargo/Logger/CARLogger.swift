//
//  CARLogger.swift
//  Cargo
//
//  Created by Med on 12/08/16.
//  Copyright © 2016 François K. All rights reserved.
//

import Foundation

/** A class that provides a logger for Cargo */
class CARLogger: NSObject {

/* ********************************* Variables Declaration ********************************* */

    /** The logging level */
    var level:TAGLoggerLogLevelType;

    /** The framework name */
    var context:String;

    /** Reference to the logger instance */
    var refToSelf:CARLogger!;

    /** Date formatter in order to log with the date */
    var formatter: NSDateFormatter!;

    /** The format used to print date in logs */
    let dateFormat = "yyyy-MM-dd HH:mm:ss.SSS ";


/* ************************************* Initializers ************************************** */

    /**
     *  Initialize the logger without a context
     *  is used when a call on carLog is made before init.
     */
    private override init() {
        self.context = "Cargo";
        self.level = kTAGLoggerLogLevelVerbose;
        self.formatter = NSDateFormatter();
        self.formatter.dateFormat = dateFormat;
        super.init();
    }

    /**
     *  Initialize the logger with a context
     *
     *  @param aContext The Context
     */
    init(aContext:String) {
        self.context = aContext;
        self.level = kTAGLoggerLogLevelVerbose;
        self.formatter = NSDateFormatter();
        self.formatter.dateFormat = dateFormat;
        super.init();
        refToSelf = self;
    }
    
    
/* ************************************ Logging methods ************************************ */

    /**
     *  Log the message
     *
     *  @param intentLevel   The level in which the message should be recorded.
     *  @param message       The message
     */
    func carLog(intentLevel:TAGLoggerLogLevelType, message:String){
        let carLogSelf = refToSelf;
        if (carLogSelf == nil) {
            refToSelf = CARLogger();
        }

        if (refToSelf.levelEnabled(intentLevel)){
            print("\(formatter.stringFromDate(NSDate()))\(refToSelf.context) [\(refToSelf.nameOfLevel(intentLevel))]:", message);
        }
    }

    /**
     *  Log a message with the context it comes from
     *
     *  @param intentLevel   The level in which the message should be recorded.
     *  @param handler       The handler the message comes from
     *  @param message       The message
     */
    func carLog(intentLevel:TAGLoggerLogLevelType, handler:CARTagHandler, message:String){
        let carLogSelf = refToSelf;
        if (carLogSelf == nil) {
            refToSelf = CARLogger();
        }

        if (refToSelf.levelEnabled(intentLevel)){
            print("\(formatter.stringFromDate(NSDate()))\(refToSelf.context) [\(refToSelf.nameOfLevel(intentLevel))] - \(handler.name) :", message);
        }
    }

    /**
     *  This method logs a warning about
     *  a missing required parameter.
     *
     *  @param paramName  The missing param name
     *  @param methodName The method name
     */
    func logMissingParam(paramName:String, methodName:String, handler:CARTagHandler) {
        carLog(kTAGLoggerLogLevelWarning, message: "[\(self.context)] Parameter '\(paramName)' is required in method '\(methodName)' of '\(handler.name)' handler");
    }

    /**
     *  This method logs a warning about an
     *  uncastable param.
     *
     *  @param paramName The uncastable param name
     *  @param type      The type
     */
    func logUncastableParam(paramName:String, type:String) {
        carLog(kTAGLoggerLogLevelWarning, message: "param \(paramName) cannot be casted to \(type) ");
    }

    /**
     *  This method logs a warning about
     *  a missing initialization of the framework
     */
    func logUninitializedFramework() {
        carLog(kTAGLoggerLogLevelWarning, message: "[\(self.context)] You must init framework before using it");
    }

    /**
     *  This method logs a setter success
     *
     *  @param paramName The set param
     *  @param value     The set value
     */
    func logParamSetWithSuccess(paramName: String, value: AnyObject) {
        carLog(kTAGLoggerLogLevelInfo, message: "[\(self.context)] Parameter '\(paramName)' has been set to '\(value)' with success");
    }

    /**
     *  This method logs a setter success with context
     *
     *  @param paramName The set param
     *  @param value     The set value
     *  @param handler   The handler
     */
    func logParamSetWithSuccess(paramName: String, value: AnyObject, handler: CARTagHandler) {
        carLog(kTAGLoggerLogLevelInfo, handler: handler, message: "[\(self.context)] Parameter '\(paramName)' has been set to '\(value)' with success");
    }

    /**
     *  This method logs a warning about an
     *  unknown param.
     *
     *  @param paramName The unknown param
     */
    func logUnknownParam(paramName:String) {
        carLog(kTAGLoggerLogLevelWarning, message: "[\(self.context)] Parameter '\(paramName)' is unknown");
    }

    /**
     *  This method logs a warning about an
     *  unknown param with context.
     *
     *  @param paramName The unknown param
     *  @param handler   The handler
     */
    func logUnknownParam(handler: CARTagHandler, paramName:String) {
        carLog(kTAGLoggerLogLevelWarning, handler: handler, message: "[\(self.context)] Parameter '\(paramName)' is unknown");
    }

    /**
     *  This method logs a warning about a
     *  missing value from a predifined value set
     *
     *  @param value          The value
     *  @param possibleValues The value set
     */
    func logNotFoundValue(value: String, key: String, possibleValues: Array<AnyObject>) {
        carLog(kTAGLoggerLogLevelWarning,
               message: "[\(self.context)] Value '\(value)' for key '\(key)' is not found among possible values \(possibleValues)");
    }



/* *********************************** Utilities methods *********************************** */

    func levelEnabled(intentLevel:TAGLoggerLogLevelType) -> Bool {
        return ((level != kTAGLoggerLogLevelNone) && (valueOf(intentLevel) >= valueOf(level)));
    }

    func valueOf(logLevel:TAGLoggerLogLevelType) -> Int {
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

    func nameOfLevel(loggingLevel:TAGLoggerLogLevelType) -> String {
        var result: String!;
        switch (loggingLevel) {
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