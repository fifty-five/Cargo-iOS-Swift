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
        self.level = TAGLoggerLogLevelType.kTAGLoggerLogLevelVerbose;
        super.init();
    }

    /**
     *  Initialize the logger with a context
     *
     *  @param aContext The Context
     */
    init(aContext:String) {
        self.context = aContext;
        self.level = TAGLoggerLogLevelType.kTAGLoggerLogLevelVerbose;
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
        carLog(TAGLoggerLogLevelType.kTAGLoggerLogLevelWarning, message: "[\(self.context)] Parameter '\(paramName)' is required in method '\(methodName)'");
    }
    
    /**
     *  This method logs a warning about an
     *  uncastable param.
     *
     *  @param paramName The uncastable param name
     *  @param type      The type
     */
    func logUncastableParam(paramName:String, type:String) {
        carLog(TAGLoggerLogLevelType.kTAGLoggerLogLevelWarning, message: "param \(paramName) cannot be casted to \(type) ");
    }
    
    /**
     *  This method logs a warning about
     *  a missing initialization of the framework
     */
    func logUninitializedFramework() {
        carLog(TAGLoggerLogLevelType.kTAGLoggerLogLevelWarning, message: "[\(self.context)] You must init framework before using it");
    }
    
    /**
     *  This method logs a setter success
     *
     *  @param paramName The set param
     *  @param value     The set value
     */
    func logParamSetWithSuccess(paramName: String, value: AnyObject) {
        carLog(TAGLoggerLogLevelType.kTAGLoggerLogLevelInfo, message: "[\(self.context)] Parameter '\(paramName)' has been set to '\(value)' with success");
    }
    
    /**
     *  This method logs a warning about an
     *  unknown param.
     *
     *  @param paramName The unknown param
     */
    func logUnknownParam(paramName:String) {
        carLog(TAGLoggerLogLevelType.kTAGLoggerLogLevelWarning, message: "[\(self.context)] Parameter '\(paramName)' is unknown");
    }
    
    /**
     *  This method logs a warning about a
     *  missing value from a predifined value set
     *
     *  @param value          The value
     *  @param possibleValues The value set
     */
    func logNotFoundValue(value: String, key: String, possibleValues: Array<AnyObject>) {
        carLog(TAGLoggerLogLevelType.kTAGLoggerLogLevelWarning,
               message: "[\(self.context)] Value '\(value)' for key '\(key)' is not found among possible values \(possibleValues)");
    }


    
/* *********************************** Utilities methods *********************************** */
    
    func levelEnabled(intentLevel:TAGLoggerLogLevelType) -> Bool {
        return ((level != TAGLoggerLogLevelType.kTAGLoggerLogLevelNone) && (intentLevel >= level));
    }
    
    func nameOfLevel(loggingLevel:TAGLoggerLogLevelType) -> String {
        var result: String!;
        switch (loggingLevel) {
            case TAGLoggerLogLevelType.kTAGLoggerLogLevelVerbose:
                result = "VERB";
                break;
            case TAGLoggerLogLevelType.kTAGLoggerLogLevelDebug:
                result = "DEBU";
                break;
            case TAGLoggerLogLevelType.kTAGLoggerLogLevelInfo:
                result = "INFO";
                break;
            case TAGLoggerLogLevelType.kTAGLoggerLogLevelWarning:
                result = "WARN";
                break;
            case TAGLoggerLogLevelType.kTAGLoggerLogLevelError:
                result = "ERRO";
                break;
            case TAGLoggerLogLevelType.kTAGLoggerLogLevelNone:
                result = "NONE";
                break;
            default:
                result = "UNKN";
                break;
        }
        return result;
    }

}