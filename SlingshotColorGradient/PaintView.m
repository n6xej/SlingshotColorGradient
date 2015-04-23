#import "PaintView.h"
#import "drawingObjects.h"

@interface PaintView()

@property (strong, nonatomic) UIBezierPath *path;   

@end

@implementation PaintView

// called when a touch is first detected on the paint view
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.bShowDraw)
	{
		NSLog(@"Paint view - touches began");
		
		// sets up self.path as a new bezier path with settings defined in the #define statements
		self.path = [UIBezierPath bezierPath];
		self.path.lineWidth = self.lineWidth;
		self.path.lineCapStyle = kCGLineCapRound;
		self.path.lineJoinStyle = kCGLineJoinRound;
		
		// sets the initial location of the path to the location of one of the touches
		UITouch *touch = [touches anyObject];
		[self.path moveToPoint:[touch locationInView:self]];
	}
}

// called when the touches have moved and the finger has not lifted yet
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.bShowDraw)
	{
		// extends self.path from its current point to the location of the new touch
		UITouch *touch = [touches anyObject];
		[self.path addLineToPoint:[touch locationInView:self]];

		[self setNeedsDisplay];
	}
}

// called when the finger is lifted
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.bShowDraw)
	{
		NSLog(@"Paint view - touches ended");
		
		// extends self.path from its current point to the location of the new touch
		UITouch *touch = [touches anyObject];
		[self.path addLineToPoint:[touch locationInView:self]];
		
		drawingObjects *dwo = [[drawingObjects alloc] init];
		
		[dwo setWidth:self.lineWidth];
		
		NSMutableDictionary *info = [NSMutableDictionary dictionary];
		
		[info setObject:self.lineColor forKey:@"penColor"];
		
		[info setObject:self.path forKey:@"path"];
		
		[info setObject:dwo forKey:@"others"];
		
		[self.drawingArray addObject:info];
		
		// updates the UI for the entire paint view
		[self setNeedsDisplay];

		[self.delegate paintView:self];
	}
}

// draws the path that is currently being tracked on the paint view
- (void)drawRect:(CGRect)rect
{
    // sets the color to the current line color and strokes the path
    [self.lineColor set];
    [self.path stroke];
}

// reset the properties used to track a path and update the UI
- (void)clearPaintView
{
    [self.path removeAllPoints];
    [self setNeedsDisplay];
}

@end
