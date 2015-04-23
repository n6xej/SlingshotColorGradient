//
//  drawingObjects.h
//  YetiSnap
//
//  Created by Christopher Worley on 6/19/14.
//  Copyright (c) 2014 Gr8Privacy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface drawingObjects : NSObject
{
	CGFloat lineWidth;
}

- (void)setWidth:(CGFloat)lw;
- (CGFloat)getWidth;

@end
