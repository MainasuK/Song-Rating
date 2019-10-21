//
//  ExceptionCatcher.m
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-4-23.
//  Copyright © 2019 Sujitech. All rights reserved.
//

#import "ExceptionCatcher.h"

@implementation ExceptionCatcher: NSObject

+ (id)catchException:(__attribute__((noescape)) id(^)(void))tryBlock error:(__autoreleasing NSError **)error {
    @try {
        return tryBlock();

    }
    @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:exception.userInfo];
        return NULL;
    }
}

@end
