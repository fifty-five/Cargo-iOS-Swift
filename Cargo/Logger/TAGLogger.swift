//
//  TAGLogger.swift
//  Cargo
//
//  Created by Med on 12/08/16.
//  Copyright © 2016 François K. All rights reserved.
//

import Foundation

/**
 * Enum for log Level setting.
 */
enum TAGLoggerLogLevelType {
    
    /** Log level of Verbose. */
    case kTAGLoggerLogLevelVerbose;
    
    /** Log level of Debug. */
    case kTAGLoggerLogLevelDebug;
    
    /** Log level of Info. */
    case kTAGLoggerLogLevelInfo;
    
    /** Log level of Warning. */
    case kTAGLoggerLogLevelWarning;
    
    /** Log level of Error. */
    case kTAGLoggerLogLevelError;
    
    /** Log level of None. */
    case kTAGLoggerLogLevelNone;
}


/**
 * A protocol for error/warning/info/debug/verbose logging.
 *
 * By default, Google Tag Manager logs error/warning messages and
 * ignores info/debug/verbose messages. You can install your own logger
 * by setting the TAGManager::logger property.
 */
protocol TAGLogger {
    
    /**
     * Logs an verbose message.
     *
     * @param message The verbose message to be logged.
     */
    func verbose(message:String);
    
    /**
     * Logs an debug message.
     *
     * @param message The debug message to be logged.
     */
    func debug(message:String);
    
    /**
     * Logs an info message.
     *
     * @param message The info message to be logged.
     */
    func info(message:String);
    
    /**
     * Logs an warning message.
     *
     * @param message The warning message to be logged.
     */
    func warning(message:String);
    
    /**
     * Logs an error message.
     *
     * @param message The error message to be logged.
     */
    func error(message:String);
    
    /**
     * Sets the log level. It is up to the implementation how the log level is used,
     * but log messages outside the log level should not be output.
     */
    func setLogLevel(logLevel:TAGLoggerLogLevelType);
    
    /**
     * Returns the current log level.
     */
    func logLevel() -> TAGLoggerLogLevelType;
    
}
