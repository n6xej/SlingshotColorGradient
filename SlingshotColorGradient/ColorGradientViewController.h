//
//  ColorGradientViewController.h
//  SlingshotColorGradient
//
//  Created by Christopher Worley on 6/19/14.
//  Copyright (c) 2014 ChristopherWorley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintView.h"

@interface CSWColorGradientViewController : UIViewController<PaintViewDelegate>

@property BOOL bShowStatusBar;
@property (weak, nonatomic) IBOutlet PaintView *paintView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) IBOutlet UIButton *undoButton;
@property (strong, nonatomic) IBOutlet UIButton *clearButton;
@property (strong, nonatomic) IBOutlet UIButton *drawButton;

@end
