//
//  JPSThumbnailAnnotationView.m
//  JPSThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

@import QuartzCore;
#import "JPSThumbnailAnnotationView.h"
#import "JPSThumbnail.h"

NSString * const kJPSThumbnailAnnotationViewReuseID = @"JPSThumbnailAnnotationView";

static CGFloat const kJPSThumbnailAnnotationViewStandardWidth     = 55.0f;
static CGFloat const kJPSThumbnailAnnotationViewStandardHeight    = 82.0f;
static CGFloat const kJPSThumbnailAnnotationViewExpandOffset      = 200.0f;
static CGFloat const kJPSThumbnailAnnotationViewVerticalOffset    = 34.0f;
static CGFloat const kJPSThumbnailAnnotationViewAnimationDuration = 0.25f;



@interface JPSThumbnailAnnotationView ()




@property (nonatomic, strong) UIButton *disclosureButton;
@property (nonatomic, assign) JPSThumbnailAnnotationViewState state;
@property (nonatomic, strong) JPSThumbnail *myThumbnail;
@end

@implementation JPSThumbnailAnnotationView


#pragma mark - Setup

- (id)initWithAnnotation:(id<MKAnnotation>)annotation {
    self = [super initWithAnnotation:annotation reuseIdentifier:kJPSThumbnailAnnotationViewReuseID];
    
    if (self) {
        self.canShowCallout = NO;
        self.clipsToBounds = YES;
        self.frame = CGRectMake(0, 0, kJPSThumbnailAnnotationViewStandardWidth, kJPSThumbnailAnnotationViewStandardHeight);
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(0, -kJPSThumbnailAnnotationViewVerticalOffset);
        
        _state = JPSThumbnailAnnotationViewStateCollapsed;
        [self setupView];
        
    }
    
    return self;
}


- (void)prepareForDisplay {
    if (!self.imageView) {
        
        
    }
    [super prepareForDisplay];
}




- (void)setupView {
    [self setupImageView];
    [self setLayerProperties];
    [self setDetailGroupAlpha:0.0f];
    //[self hideDisclosureButton];
}

- (NSString *)accessibilityLabel {
    return [NSString stringWithFormat:@"Map Pin: %@ %@", self.titleLabel.text, self.subtitleLabel.text];
}

- (BOOL)accessibilityActivate {
    [self didTapDisclosureButton];
    return YES;
}

- (void)setupImageView {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 35.0f, 47.0f)];
    _imageView.layer.cornerRadius = 4.0f;
    _imageView.layer.masksToBounds = YES;
    _imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    _imageView.layer.borderWidth = 1.0f;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.tintColor = [UIColor whiteColor];
    [self addSubview:_imageView];
}

- (void)setupTitleLabel {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kJPSThumbnailAnnotationViewStandardWidth, 14.0f, 157.0f, 20.0f)];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:17];
    _titleLabel.minimumScaleFactor = 0.8f;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_titleLabel];
}

- (void)setupSubtitleLabel {
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kJPSThumbnailAnnotationViewStandardWidth, 34.0f, 157.0f, 20.0f)];
    _subtitleLabel.textColor = [UIColor lightTextColor];
    _subtitleLabel.font = [UIFont systemFontOfSize:12.0f];
    [self addSubview:_subtitleLabel];
}

- (void)setupDisclosureButton {
    BOOL iOS7 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f;
    UIButtonType buttonType = iOS7 ? UIButtonTypeSystem : UIButtonTypeCustom;
    _disclosureButton = [UIButton buttonWithType:buttonType];
    _disclosureButton.tintColor = [UIColor whiteColor];
    UIImage *disclosureIndicatorImage = [JPSThumbnailAnnotationView disclosureButtonImage];
    [_disclosureButton setImage:disclosureIndicatorImage forState:UIControlStateNormal];
    _disclosureButton.frame = CGRectMake(kJPSThumbnailAnnotationViewExpandOffset + self.frame.size.width/4.0f + 4.0f,
                                         7,
                                         disclosureIndicatorImage.size.width * 2,
                                         53);
    
    [_disclosureButton addTarget:self action:@selector(didTapDisclosureButton) forControlEvents:UIControlEventTouchDown];
    [self addSubview:_disclosureButton];
    
    [_disclosureButton setContentMode:UIViewContentModeCenter];
    //_disclosureButton.backgroundColor = [UIColor yellowColor];
    
    CGSize mainViewSize = _disclosureButton.bounds.size;
    CGFloat borderWidth = .5;
    UIColor *borderColor = [UIColor whiteColor];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, borderWidth, mainViewSize.height)];
    leftView.opaque = YES;
    leftView.backgroundColor = borderColor;
    // for bonus points, set the views' autoresizing mask so they'll stay with the edges:
    leftView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    
    [_disclosureButton addSubview:leftView];
}

- (void) hideDisclosureButton {
    self.disclosureButton.hidden = YES;
}

- (void)setLayerProperties {
    _bgLayer = [CAShapeLayer layer];
    CGPathRef path = [self newBubbleWithRect:self.bounds];
    _bgLayer.path = path;
    CFRelease(path);
    _bgLayer.fillColor = [UIColor colorWithRed:0./255. green:85./255. blue:40./255. alpha:1.0f].CGColor;
    
    _bgLayer.shadowColor = [UIColor blackColor].CGColor;
    _bgLayer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    _bgLayer.shadowRadius = 2.0f;
    _bgLayer.shadowOpacity = 0.5f;
    
    _bgLayer.masksToBounds = NO;
    
    [self.layer insertSublayer:_bgLayer atIndex:0];
}

#pragma mark - Updating

- (void)updateWithThumbnail:(JPSThumbnail *)thumbnail {
    self.coordinate = thumbnail.coordinate;
    self.myThumbnail = thumbnail;
    @autoreleasepool {
        self.imageView.image = [UIImage imageNamed:thumbnail.imageName];
    }


    


}

#pragma mark - JPSThumbnailAnnotationViewProtocol

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView {
    // Center map at annotation point
    [mapView setCenterCoordinate:self.coordinate animated:YES];
    [self expand];
}

- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView {
    [self shrink];
}

#pragma mark - Geometry


- (UIEdgeInsets)alignmentRectInsets {
    if (self.state == JPSThumbnailAnnotationViewStateCollapsed) {
        static UIEdgeInsets const collapsedAlignRectInsets = {6, 6, 6, 6};
        
        return collapsedAlignRectInsets;
    }
    UIEdgeInsets temp = UIEdgeInsetsMake(self.frame.size.height/2.0, self.frame.size.width/2.0, self.frame.size.height/2.0, self.frame.size.width/2.0);
    
    return temp;
    
}


- (CGPathRef)newBubbleWithRect:(CGRect)rect {
    CGFloat stroke = 1.0f;
    CGFloat radius = 7.0f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat parentX = rect.origin.x + rect.size.width/2.0f;
    
    // Determine Size
    rect.size.width -= stroke + 14.0f;
    rect.size.height -= stroke + 29.0f;
    rect.origin.x += stroke / 2.0f + 7.0f;
    rect.origin.y += stroke / 2.0f + 7.0f;
    
    // Create Callout Bubble Path
    CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + radius);
    CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI_2, 1);
    CGPathAddLineToPoint(path, NULL, parentX - 14.0f, rect.origin.y + rect.size.height);
    CGPathAddLineToPoint(path, NULL, parentX, rect.origin.y + rect.size.height + 14.0f);
    CGPathAddLineToPoint(path, NULL, parentX + 14.0f, rect.origin.y + rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI_2, 0.0f, 1.0f);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI_2, 1.0f);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + radius, rect.origin.y);
    CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI_2, M_PI, 1.0f);
    CGPathCloseSubpath(path);
    return path;
}

#pragma mark - Animations

- (void)setDetailGroupAlpha:(CGFloat)alpha {
    self.disclosureButton.alpha = alpha;
    self.titleLabel.alpha = alpha;
    self.subtitleLabel.alpha = alpha;
}

- (void) expand {
    [self expandAnimated:YES];
}
- (void)expandAnimated: (BOOL) animated {
    
    if (_titleLabel == nil) {
        [self setupTitleLabel];
        [self setupSubtitleLabel];
        [self setupDisclosureButton];
    }

    
    self.titleLabel.text = self.myThumbnail.title;
    self.subtitleLabel.text = self.myThumbnail.subtitle;
    
    if (self.state != JPSThumbnailAnnotationViewStateCollapsed) return;
    
    self.state = JPSThumbnailAnnotationViewStateAnimating;
    
    
    [self animateBubbleWithDirection:JPSThumbnailAnnotationViewAnimationDirectionGrow animated:animated];
    
    //self.centerOffset = CGPointMake(kJPSThumbnailAnnotationViewExpandOffset/2.0f, -kJPSThumbnailAnnotationViewVerticalOffset);
    if (animated) {
        [UIView animateWithDuration:kJPSThumbnailAnnotationViewAnimationDuration delay: 0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             self.bounds = CGRectMake(0, 0, kJPSThumbnailAnnotationViewStandardWidth + kJPSThumbnailAnnotationViewExpandOffset, self.frame.size.height);
                             
                         } completion:^(BOOL finished) {
                             [self setDetailGroupAlpha:1.0f];
                             self.state = JPSThumbnailAnnotationViewStateExpanded;
                             
                         }];
    } else {
        [self setDetailGroupAlpha:1.0f];
        self.bounds = CGRectMake(0, 0, kJPSThumbnailAnnotationViewStandardWidth + kJPSThumbnailAnnotationViewExpandOffset, self.frame.size.height);
        self.state = JPSThumbnailAnnotationViewStateExpanded;
    }
    [CATransaction commit];
    
    
}

- (void)shrink {
    if (self.state != JPSThumbnailAnnotationViewStateExpanded) return;
    
    self.state = JPSThumbnailAnnotationViewStateAnimating;
    
    [self setDetailGroupAlpha:0.0f];
    [UIView animateWithDuration:kJPSThumbnailAnnotationViewAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.bounds = CGRectMake(0,
                                                  0,
                                                  kJPSThumbnailAnnotationViewStandardWidth,
                                                  kJPSThumbnailAnnotationViewStandardHeight);
                         
                     }
                     completion:^(BOOL finished) {
                         
                         //self.centerOffset = CGPointMake(0.0f, -kJPSThumbnailAnnotationViewVerticalOffset);
                     }];
    [self animateBubbleWithDirection:JPSThumbnailAnnotationViewAnimationDirectionShrink];
    
}


- (void)animateBubbleWithDirection:(JPSThumbnailAnnotationViewAnimationDirection)animationDirection {
    [self animateBubbleWithDirection:animationDirection animated:YES];
}
- (void)animateBubbleWithDirection:(JPSThumbnailAnnotationViewAnimationDirection)animationDirection animated: (BOOL) animated {
    BOOL growing = (animationDirection == JPSThumbnailAnnotationViewAnimationDirectionGrow);
    // Image
    
    if (animated) {
        
        
        [UIView animateWithDuration:kJPSThumbnailAnnotationViewAnimationDuration animations:^{
        } completion:^(BOOL finished) {
            if (animationDirection == JPSThumbnailAnnotationViewAnimationDirectionShrink) {
                self.state = JPSThumbnailAnnotationViewStateCollapsed;
            }
        }];
        
        
        
        // Bubble
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.repeatCount = 1;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.duration = kJPSThumbnailAnnotationViewAnimationDuration;
        
        // Stroke & Shadow From/To Values
        //CGRect largeRect = CGRectInset(self.bounds, -kJPSThumbnailAnnotationViewExpandOffset/2.0f, 0.0f);
        CGRect largeRect = CGRectMake(0, 0, self.bounds.size.width + kJPSThumbnailAnnotationViewExpandOffset, self.bounds.size.height);
        
        CGPathRef fromPath = [self newBubbleWithRect:growing ? self.bounds : largeRect];
        animation.fromValue = (__bridge id)fromPath;
        CGPathRelease(fromPath);
        
        CGPathRef toPath = [self newBubbleWithRect:growing ? largeRect : self.bounds];
        animation.toValue = (__bridge id)toPath;
        CGPathRelease(toPath);
        
        [self.bgLayer addAnimation:animation forKey:animation.keyPath];
    } else {
        //CGFloat xOffset = (growing ? -1 : 1) * kJPSThumbnailAnnotationViewExpandOffset/2.0f;
        //self.imageView.frame = CGRectOffset(self.imageView.frame, xOffset, 0.0f);
        if (animationDirection == JPSThumbnailAnnotationViewAnimationDirectionShrink) {
            self.state = JPSThumbnailAnnotationViewStateCollapsed;
        }
        CGRect largeRect = CGRectMake(0, 0, self.bounds.size.width + kJPSThumbnailAnnotationViewExpandOffset, self.bounds.size.height);
        self.bgLayer.path = [self newBubbleWithRect:growing ? largeRect : self.bounds];
    }
    
    
    
}

#pragma mark - Disclosure Button

- (void)didTapDisclosureButton {
    
  
}

+ (UIImage *)disclosureButtonImage {
    CGSize size = CGSizeMake(21.0f, 20.0f);
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(2.0f, 2.0f)];
    [bezierPath addLineToPoint:CGPointMake(10.0f, 10.0f)];
    [bezierPath addLineToPoint:CGPointMake(2.0f, 18.0f)];
    [[UIColor lightGrayColor] setStroke];
    bezierPath.lineWidth = 3.0f;
    [bezierPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

