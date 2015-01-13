//
//  NSString+DrawFixer.m
//  SpriteTests
//
//  Created by Brennon Bortz on 1/12/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

#import "NSString+DrawFixer.h"

// not my solution: see http://stackoverflow.com/a/25029448/341994
@implementation NSString (Drawfixer)

+ (NSStringDrawingOptions) combine:(NSStringDrawingOptions)option1 with:(NSStringDrawingOptions)option2
{
    return option1 | option2;
}

@end
