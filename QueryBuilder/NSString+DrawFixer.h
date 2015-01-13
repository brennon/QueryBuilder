//
//  NSString+DrawFixer.h
//  SpriteTests
//
//  Created by Brennon Bortz on 1/12/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Drawfixer)
+ (NSStringDrawingOptions) combine:(NSStringDrawingOptions)option1 with:(NSStringDrawingOptions)option2;
@end
