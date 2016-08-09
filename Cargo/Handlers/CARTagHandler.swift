//
//  CARTagHandler.swift
//  SwiftSampleApp
//
//  Created by François K on 09/08/2016.
//  Copyright © 2016 François K. All rights reserved.
//

import Foundation

class CARTagHandler {
    var key: AnyObject? ;
    var name: String? ;
    var initialized: Bool? ;
    var valid: Bool? ;
    
    func execute(functionName : String, parameters:Dictionary<String, AnyObject>){
        print("Function \(functionName) has been received with parameters \(parameters) ");
    }
    
    func validate(){
        valid = true;
    }
}

