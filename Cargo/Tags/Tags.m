//
//  Tags.m
//  Cargo
//
//  Created by Julien Gil on 06/03/2017.
//  Copyright © 2017 François K. All rights reserved.
//

#import "Tags.h"
#import "Cargo-Swift.h"

@implementation Tags

- (NSObject*)executeWithParameters:(NSDictionary*)parameters {
    [[Cargo getInstance] execute:parameters];
    [CargoItem notifyTagFired];
    return nil;
}

@end
