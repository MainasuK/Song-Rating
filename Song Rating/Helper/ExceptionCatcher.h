//
//  ExceptionCatcher.h
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-4-23.
//  Copyright © 2019 Sujitech. All rights reserved.
//

#ifndef ExceptionCatcher_h
#define ExceptionCatcher_h

#import <Foundation/Foundation.h>

@interface ExceptionCatcher: NSObject

+ (id)catchException:(__attribute__((noescape)) id(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end

#endif /* ExceptionCatcher_h */
