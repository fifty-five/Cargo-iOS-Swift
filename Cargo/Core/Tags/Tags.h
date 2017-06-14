//
//  Tags.h
//  Cargo
//
//  Created by Julien Gil on 06/03/2017.
//  Copyright © 2017 François K. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GoogleTagManager;

@interface Tags : NSObject <TAGCustomFunction>

- (NSObject*)executeWithParameters:(NSDictionary*)parameters;

@end
