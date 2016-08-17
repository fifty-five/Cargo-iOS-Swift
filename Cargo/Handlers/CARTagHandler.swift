//
//  CARTagHandler.swift
//  SwiftSampleApp
//
//  Created by François K on 09/08/2016.
//  Copyright © 2016 François K. All rights reserved.
//

import Foundation

class CARTagHandler : NSObject, TAGFunctionCallTagHandler {
    
    var key: String;
    var name: String;
    var initialized: Bool = false ;
    var valid: Bool = false;

    let cargo = Cargo.sharedHelper;

    init(key:String, name:String){
        self.key = key;
        self.name = name;
    }

    func execute(tagName:String, parameters:[NSObject : AnyObject]!){
        print("Function \(tagName) has been received with parameters \(parameters) ");
    }

    func noTagMatch(handler: CARTagHandler, tagName: String) {
        let infoMessage = "\(tagName) does not match any known tag in handler \(handler.name)";
        cargo.logger.carLog(kTAGLoggerLogLevelInfo, message: infoMessage);
    }

    func validate(){
        valid = true;
    }

}
