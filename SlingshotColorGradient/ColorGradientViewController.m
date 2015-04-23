//
//  ColorGradientViewController.m
//  SlingshotColorGradient
//
//  Created by Christopher Worley on 6/19/14.
//  Copyright (c) 2014 ChristopherWorley. All rights reserved.
//

#import "ColorGradientViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "drawingObjects.h"
#import "IonIcons.h"

#define BUBBLEHEIGHT 50
#define PENFRAMEWIDTH 100
#define GRADIENTHEIGHT 6
#define MAXPENSIZE 50.0f
#define MINPENSIZE 5.0f
#define LINE_WIDTH 15
#define STATUSBAR_HEIGHT 0 // set to 20 to compensate for status bar

@implementation CSWColorGradientViewController
{
	UIImageView *gradientColorImage;
	IBOutlet UIImageView *bubbleView;
	UIView *gradientColorView;
	UIView *gradientPenView;
	CAGradientLayer *layer;
	CAShapeLayer *circleLayerInner;
	CAShapeLayer *circleLayerOuter;
	UIPanGestureRecognizer *panGesture;
	UIImage *drawButtonN;
	UIImage *drawButtonSel;
	UIColor *myPen;
	BOOL bInGradient;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIImage *undoIcon = [IonIcons imageWithIcon:icon_ios7_undo
										   size:30.0f
										  color:[UIColor whiteColor]];
	
	[self.undoButton setBackgroundImage:undoIcon forState:UIControlStateNormal];
	
	UIImage *clearIcon = [IonIcons imageWithIcon:icon_ios7_close_empty
											size:30.0f
										   color:[UIColor whiteColor]];
	
	[self.clearButton setBackgroundImage:clearIcon forState:UIControlStateNormal];
	
	drawButtonN = [UIImage imageNamed:@"Draw"];
	drawButtonSel = [UIImage imageNamed:@"DrawSelected"];
	
	[self.drawButton setBackgroundImage:drawButtonN forState:UIControlStateNormal];
	
	CGRect mainBounds = [[UIScreen mainScreen] bounds];

	_originalImage = [UIImage imageNamed:@"background"];

	gradientPenView =[[UIView alloc] initWithFrame:CGRectMake(mainBounds.size.width-PENFRAMEWIDTH, 0, PENFRAMEWIDTH, mainBounds.size.height)];
	
	[self.view addSubview:gradientPenView];
	[gradientPenView removeFromSuperview];
	
	gradientColorView =[[UIView alloc] initWithFrame:CGRectMake(mainBounds.size.width-GRADIENTHEIGHT, STATUSBAR_HEIGHT, GRADIENTHEIGHT, mainBounds.size.height)];
	gradientColorImage =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GRADIENTHEIGHT, mainBounds.size.height-STATUSBAR_HEIGHT)];
		
    layer =[CAGradientLayer layer];
	
	 [layer setFrame:CGRectMake(0, 0, GRADIENTHEIGHT, mainBounds.size.height-STATUSBAR_HEIGHT)];

	layer.colors =@[(id)[UIColor blackColor].CGColor,
					//(id)[UIColor darkGrayColor].CGColor,
					//(id)[UIColor lightGrayColor].CGColor,
					(id)[UIColor whiteColor].CGColor,
					//(id)[UIColor grayColor].CGColor,
					(id)[UIColor redColor].CGColor,
					(id)[UIColor brownColor].CGColor,
					(id)[UIColor orangeColor].CGColor,
					(id)[UIColor yellowColor].CGColor,
					(id)[UIColor greenColor].CGColor,
					(id)[UIColor cyanColor].CGColor,
					(id)[UIColor blueColor].CGColor,
					(id)[UIColor magentaColor].CGColor,
					(id)[UIColor purpleColor].CGColor];

	layer.startPoint =CGPointMake(.5, 0);
    layer.endPoint =CGPointMake(.5, 1);
	
	[gradientColorImage.layer addSublayer:layer];
	
	[gradientColorView addSubview:gradientColorImage];
	[self.view addSubview:gradientColorView];
	
	panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
														 action:@selector(drag:)];
	[gradientColorView addGestureRecognizer:panGesture];
	
	self.paintView.bShowDraw = NO;
	gradientColorView.hidden = YES;
	
	self.paintView.lineWidth = LINE_WIDTH;
    // sets the default 'paint' color in the PaintView
    self.paintView.lineColor = [UIColor redColor];
	
    self.paintView.delegate = self;
    self.imageView.image = self.originalImage;
	
	self.paintView.drawingArray = [NSMutableArray array];

	
	bInGradient = NO;

	self.bShowStatusBar = YES;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResign)
									name:UIApplicationWillResignActiveNotification object:nil];

}

- (BOOL)prefersStatusBarHidden {
    return self.bShowStatusBar;
}

- (void) applicationWillResign
{
	// if pen bubble is visible and lock is pushed this removes the layer
	if (bInGradient)
	{
		[gradientPenView removeFromSuperview];
		[circleLayerInner removeFromSuperlayer];
		[circleLayerOuter removeFromSuperlayer];

		bInGradient=NO;
	}
}

- (void)drawYCircleView:(CGPoint)p  withOffset:(CGFloat)yOffset withQ:(CGPoint)q
{
	if (yOffset < 0.0f)
	{
		yOffset = 0.0f;
	}
	
	if (yOffset > layer.frame.size.height)
	{
		yOffset = layer.frame.size.height;
	}
	
	CGFloat gap=(layer.frame.size.height/(layer.colors.count-1));
	NSInteger index = yOffset/gap;
	yOffset =yOffset -index*gap;
	
	UIColor *color1=[UIColor colorWithCGColor:(CGColorRef)layer.colors[index]];
	
	if (index>layer.colors.count-2)
	{
		index=layer.colors.count-2;
	}
	
	UIColor *color2=[UIColor colorWithCGColor:(CGColorRef)layer.colors[index+1]];
	CGFloat r1,g1,b1,a1,r2,g2,b2,a2;
	[color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
	[color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
	
	myPen =[UIColor colorWithRed:(1-(yOffset/gap))*r1 +(yOffset/gap)*r2 green:(1-(yOffset/gap))*g1 +(yOffset/gap)*g2 blue:(1-(yOffset/gap))*b1 +(yOffset/gap)*b2 alpha:1.0];

	CGFloat penSize = ([gradientPenView bounds].size.width - q.x)/([gradientPenView bounds].size.width/MAXPENSIZE);
	
	if (penSize < MINPENSIZE)
	{
		penSize = MINPENSIZE;
	}
	else if (penSize > MAXPENSIZE)
	{
		penSize = MAXPENSIZE;
	}
	
	[circleLayerInner removeFromSuperlayer];
	[circleLayerOuter removeFromSuperlayer];
	circleLayerOuter = [CAShapeLayer layer];
	
	CGFloat screenWidth = [bubbleView bounds].size.width/2.0f;
	CGFloat screenHeight = [bubbleView bounds].size.height/2.0f;
	
	
	// Give the layer the same bounds as your image view
	[circleLayerOuter setBounds:CGRectMake(screenWidth-BUBBLEHEIGHT/2, screenHeight-BUBBLEHEIGHT/2, BUBBLEHEIGHT,BUBBLEHEIGHT)];
	
	// Position the circle anywhere you like, but this will center it
	// In the parent layer, which will be your image view's root layer
	[circleLayerOuter setPosition:CGPointMake(screenWidth,
											  screenHeight)];
	
	UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:
						  CGRectMake(screenWidth-BUBBLEHEIGHT/2, screenHeight-BUBBLEHEIGHT/2, BUBBLEHEIGHT,BUBBLEHEIGHT)];
	// Set the path on the layer
	[circleLayerOuter setPath:[path CGPath]];
	// Set the stroke color
	[circleLayerOuter setStrokeColor:[myPen CGColor]];
	[circleLayerOuter setFillColor:[[UIColor whiteColor]  CGColor]];
	// Set the stroke line width
	[circleLayerOuter setLineWidth:1.0f];
	
	
	[[bubbleView layer] addSublayer:circleLayerOuter];
	
	circleLayerInner = [CAShapeLayer layer];
	
	// Give the layer the same bounds as your image view
	[circleLayerInner setBounds:CGRectMake(screenWidth-BUBBLEHEIGHT/2, screenHeight-BUBBLEHEIGHT/2, BUBBLEHEIGHT,BUBBLEHEIGHT)];
	
	// Position the circle anywhere you like, but this will center it
	// In the parent layer, which will be your image view's root layer
	[circleLayerInner setPosition:CGPointMake(screenWidth,
											  screenHeight)];
	
	path = [UIBezierPath bezierPathWithOvalInRect:
			CGRectMake(screenWidth-penSize/2.0f, screenHeight-penSize/2.0f, penSize, penSize)];
	// Set the path on the layer
	[circleLayerInner setPath:[path CGPath]];
	// Set the stroke color
	[circleLayerInner setStrokeColor:[myPen CGColor]];
	[circleLayerInner setFillColor:[myPen CGColor]];
	// Set the stroke line width
	[circleLayerInner setLineWidth:0.0f];
	
	// Add the sublayer to the image view's layer tree
	[[bubbleView layer] addSublayer:circleLayerInner];
	
	self.paintView.lineWidth = penSize;
    // sets the default 'paint' color in the PaintView
    self.paintView.lineColor = myPen;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint p = [[touches anyObject] locationInView:gradientColorView];
	CGPoint q = [[touches anyObject] locationInView:gradientPenView];
	
	if(CGRectContainsPoint(layer.frame, p))
	{
		NSLog(@"Touch started in gradient");
		bInGradient = YES;
		[self.view addSubview:gradientPenView];
		
		CGFloat yOffset = (p.y - layer.frame.origin.y);

		[self drawYCircleView:p withOffset:yOffset withQ:q];
	}
	else
	{
		NSLog(@"Touch started outside gradient");
		bInGradient = NO;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"Touch ended");
	
	if (bInGradient)
	{
		[gradientPenView removeFromSuperview];
		dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 400000000); // .4 seconds
		dispatch_after(time, dispatch_get_main_queue(), ^()
		   {
			   // remove our draw object
			   [circleLayerInner removeFromSuperlayer];
			   [circleLayerOuter removeFromSuperlayer];
		   });
		CABasicAnimation *theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
		theAnimation.duration=0.60;
		theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
		theAnimation.toValue=[NSNumber numberWithFloat:0.0];
		theAnimation.removedOnCompletion   =   NO;
		[circleLayerOuter addAnimation:theAnimation forKey:@"animateOpacity"];
		[circleLayerInner addAnimation:theAnimation forKey:@"animateOpacity"];
		
		bInGradient=NO;
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[circleLayerInner removeFromSuperlayer];
	[circleLayerOuter removeFromSuperlayer];
}

- (void)drag:(UIPanGestureRecognizer *)pan
{
	if (pan.state == UIGestureRecognizerStateEnded)
	{
		NSLog(@"Finger lifter");
		if (bInGradient)
		{
			[gradientPenView removeFromSuperview];
			dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 400000000); // .4 seconds
			dispatch_after(time, dispatch_get_main_queue(), ^()
			   {
				   // remove our draw object
				   [circleLayerInner removeFromSuperlayer];
				   [circleLayerOuter removeFromSuperlayer];
			   });
			CABasicAnimation *theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
			theAnimation.duration=0.6;
			theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
			theAnimation.toValue=[NSNumber numberWithFloat:0.0];
			theAnimation.removedOnCompletion   =   NO;
			[circleLayerOuter addAnimation:theAnimation forKey:@"animateOpacity"];
			[circleLayerInner addAnimation:theAnimation forKey:@"animateOpacity"];
			
			bInGradient=NO;
		}
		return;
	}
	
	if (bInGradient)
	{
		CGPoint p = [pan locationInView:gradientColorView];
		CGPoint q = [pan locationInView:gradientPenView];
		CGFloat yOffset = (p.y - layer.frame.origin.y);

		[self drawYCircleView:p withOffset:yOffset withQ:q];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Drawing merge methods

// Receives the area that was painted from the paint view after the user is finished drawing a path
- (void)paintView:(PaintView *)paintView //finishedTrackingPathInRect:(CGRect)paintedArea
{
    NSLog(@"Delegate received dirty rect");
	
	self.undoButton.hidden = NO;
	self.clearButton.hidden = NO;
	
	self.imageView.image = self.originalImage;
	
	// Creating a new offscreen buffer to merge the images in
	CGRect bounds = self.imageView.bounds;
	UIGraphicsBeginImageContextWithOptions(bounds.size, NO, self.imageView.contentScaleFactor);
	
	
	for (NSMutableDictionary *subArray in self.paintView.drawingArray)
	{
		drawingObjects *dwo = [subArray objectForKey:@"others"];
		CGFloat lineWidth = [dwo getWidth];
		//		CGRect dirty = [dwo getDirty];
		UIColor *lineColor = [subArray objectForKey:@"penColor"];
		UIBezierPath *path = [subArray objectForKey:@"path"];
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		// Copying the image currently in self.imageView into the context
	    CGContextSetBlendMode(context, kCGBlendModeCopy);
		[self.imageView.layer renderInContext:context];
		
		CGContextClipToRect(context, bounds);
		CGContextSetLineWidth(context, lineWidth);
		CGContextSetLineCap(context, kCGLineCapRound);
		CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
		CGContextAddPath(context, [path CGPath]);
		CGContextStrokePath(context);
		self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
		
		[self.paintView setNeedsDisplay];
	}
	
	UIGraphicsEndImageContext();
}

// Combines the user's recently painted path with the image in self.imageView
- (void)mergePaintToBackgroundView:(CGRect)painted
{
    NSLog(@"Merging paint view into background view");
	
	self.imageView.image = self.originalImage;
    
    // Creating a new offscreen buffer to merge the images in
    CGRect bounds = self.imageView.bounds;
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, self.imageView.contentScaleFactor);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Copying the image currently in self.imageView into the context
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    [self.imageView.layer renderInContext:context];
	
    // Copying the recently painted path from the paint view and putting it on top of the image in the context.
    // As an optimization, the clip area is set to we only copy the area of paint view that was actually drawn on.
    CGContextClipToRect(context, painted);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [self.paintView.layer renderInContext:context];
	
    // Now that the paint view has been merged with the imageView, we can clear the paint view
    [self.paintView clearPaintView];
    
    // Creating an image from the graphics context and setting the current image onscreen to it
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    self.imageView.image = image;
    UIGraphicsEndImageContext();
}

#pragma mark - Paint button methods

- (IBAction)clearDrawing:(id)sender
{
	// remove any drawing
	[self.paintView clearPaintView];
	[self.paintView.drawingArray removeAllObjects];
	self.imageView.image = self.originalImage;
	self.undoButton.hidden = YES;
	self.clearButton.hidden = YES;
}

- (IBAction)undoLast
{
    if (self.paintView.drawingArray.count < 2)
    {
        self.undoButton.hidden = YES;
		self.clearButton.hidden = YES;
		self.imageView.image = self.originalImage;
		[self.paintView clearPaintView];
		[self.paintView.drawingArray removeAllObjects];
    }
    else
    {
		self.undoButton.hidden = NO;
		self.clearButton.hidden = NO;
		[self.paintView clearPaintView];
        [self.paintView.drawingArray removeLastObject];
		self.imageView.image = self.originalImage;
		
		// Creating a new offscreen buffer to merge the images in
		CGRect bounds = self.imageView.bounds;
		UIGraphicsBeginImageContextWithOptions(bounds.size, NO, self.imageView.contentScaleFactor);
		
		
		for (NSMutableDictionary *subArray in self.paintView.drawingArray)
		{
			drawingObjects *dwo = [subArray objectForKey:@"others"];
			CGFloat lineWidth = [dwo getWidth];
			UIColor *lineColor = [subArray objectForKey:@"penColor"];
			UIBezierPath *path = [subArray objectForKey:@"path"];
			
			CGContextRef context = UIGraphicsGetCurrentContext();
			
			// Copying the image currently in self.imageView into the context
			CGContextSetBlendMode(context, kCGBlendModeCopy);
			[self.imageView.layer renderInContext:context];
			
			CGContextClipToRect(context, bounds);
			
			CGContextSetLineWidth(context, lineWidth);
			CGContextSetLineCap(context, kCGLineCapRound);
			CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
			CGContextAddPath(context, [path CGPath]);
			CGContextStrokePath(context);
			self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
		}
		
		UIGraphicsEndImageContext();
    }
}

- (IBAction)drawButton:(id)sender
{
	if (self.paintView.bShowDraw)
	{
		CABasicAnimation *theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
		theAnimation.duration=0.25;
		theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
		theAnimation.toValue=[NSNumber numberWithFloat:0.0];
		theAnimation.removedOnCompletion   =   NO;
		[gradientColorView.layer addAnimation:theAnimation forKey:@"animateOpacity"];
		gradientColorView.alpha = 0.0f;
		
		[self.drawButton setBackgroundImage:drawButtonN forState:UIControlStateNormal];
		self.paintView.bShowDraw = NO;
		self.bShowStatusBar = NO;

		// iOS 7
		[self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
	}
	else
	{
		gradientColorView.alpha = 0.0f;
		gradientColorView.hidden = NO;
		
		CABasicAnimation *theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
		theAnimation.duration=0.25;
		theAnimation.fromValue=[NSNumber numberWithFloat:0.0];
		theAnimation.toValue=[NSNumber numberWithFloat:1.0];
		theAnimation.removedOnCompletion   =   NO;
		[gradientColorView.layer addAnimation:theAnimation forKey:@"animateOpacity"];
		gradientColorView.alpha = 1.0f;

		[self.drawButton setBackgroundImage:drawButtonSel forState:UIControlStateNormal];
		self.paintView.bShowDraw = YES;
		self.bShowStatusBar = YES;

		// iOS 7
		[self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
	}
}

@end
