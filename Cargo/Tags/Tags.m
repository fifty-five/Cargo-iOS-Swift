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

/**
 Function Call tags let you execute pre-registered functions (e.g. to trigger hits for additional 
 measurement tools that are not currently supported with tag templates in Google Tag Manager).

 @param parameters The parameters of the event received
 @return nil
 */
- (NSObject*)executeWithParameters:(NSDictionary*)parameters {
    // redirects the call to the Cargo Class which handles it.
    [[Cargo getInstance] execute:parameters];
    // notifies the CargoItem class that a tag has been fired.
    [CargoItem notifyTagFired];
    return nil;
}

@end
