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
    


/* ************************************* Initializers ************************************** */

    /**
     *  Initialize the logger without a context
     *  is used when a call on carLog is made before init.
     */
    private override init() {
        self.context = "Cargo";
        self.level = kTAGLoggerLogLevelVerbose;
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
            print(refToSelf.context, refToSelf.nameOfLevel(intentLevel), message);
        }
    }
    
    /**
     *  This method logs a warning about
     *  a missing required parameter.
     *
     *  @param paramName  The missing param name
     *  @param methodName The method name
     */
    func logMissingParam(paramName:String, methodName:String) {
        carLog(kTAGLoggerLogLevelWarning, message: "[\(self.context)] Parameter '\(paramName)' is required in method '\(methodName)'");
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
     *  This method logs a warning about an
     *  unknown param.
     *
     *  @param paramName The unknown param
     */
    func logUnknownParam(paramName:String) {
        carLog(kTAGLoggerLogLevelWarning, message: "[\(self.context)] Parameter '\(paramName)' is unknown");
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
            result = 5;
            break;
        case kTAGLoggerLogLevelDebug:
            result = 4;
            break;
        case kTAGLoggerLogLevelInfo:
            result = 3;
            break;
        case kTAGLoggerLogLevelWarning:
            result = 2;
            break;
        case kTAGLoggerLogLevelError:
            result = 1;
            break;
        default:
            result = 0;
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