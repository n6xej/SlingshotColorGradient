//
//  drawingObjects.m
//  YetiSnap
//
//  Created by Christopher Worley on 6/19/14.
//  Copyright (c) 2014 Gr8Privacy. All rights reserved.
//

#import "drawingObjects.h"

@implementation drawingObjects

- (id)init
{
	if (self = [super init])
	{

	}
	return self;
}

- (void)setWidth:(CGFloat)lw
{
	lineWidth = lw;
}

- (CGFloat)getWidth
{
	return lineWidth;
}

@end
