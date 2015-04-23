#import <UIKit/UIKit.h>

@protocol PaintViewDelegate;

@interface PaintView : UIView

@property (nonatomic, weak) id <PaintViewDelegate> delegate;
@property (strong, nonatomic) UIColor *lineColor;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) NSMutableArray *drawingArray;
@property (nonatomic) BOOL bShowDraw;

- (void)clearPaintView;

@end

@protocol PaintViewDelegate <NSObject>

- (void)paintView:(PaintView *)paintView;

@end




