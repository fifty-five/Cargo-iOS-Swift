//
//  Tags.swift
//  Cargo
//
//  Created by Julien Gil on 20/01/2017.
//  Copyright © 2017 François K. All rights reserved.
//

import Foundation
import GoogleTagManager

class Tags: NSObject, TAGCustomFunction {
    
    required override init() {
        Cargo.sharedHelper.logger.carLog(.error, message: "OBOBOBOBOBOBOBOBOBOBOBOBOBOBOBOBOB");
    }
    
    func execute(withParameters parameters: [AnyHashable : Any]!) -> NSObject! {
        Cargo.sharedHelper.execute(parameters);
        Cargo.sharedHelper.logger.carLog(.error, message: "BABABAABABABBABABABABABBBAABAABABABBA");
        return nil;
    }
}
