//
//  JPSThumbnailAnnotationView.h
//  JPSThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

@import MapKit;

@class JPSThumbnail;

extern NSString * const kJPSThumbnailAnnotationViewReuseID;

typedef NS_ENUM(NSInteger, JPSThumbnailAnnotationViewAnimationDirection) {
    JPSThumbnailAnnotationViewAnimationDirectionGrow,
    JPSThumbnailAnnotationViewAnimationDirectionShrink,
};

typedef NS_ENUM(NSInteger, JPSThumbnailAnnotationViewState) {
    JPSThumbnailAnnotationViewStateCollapsed,
    JPSThumbnailAnnotationViewStateExpanded,
    JPSThumbnailAnnotationViewStateAnimating,
};

@protocol JPSThumbnailAnnotationViewProtocol <NSObject>

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView;
- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView;

@end

@interface JPSThumbnailAnnotationView : MKAnnotationView <JPSThumbnailAnnotationViewProtocol>
@property (nonatomic, strong) CAShapeLayer *bgLayer;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIColor *annotationColor;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

- (void)updateWithThumbnail:(JPSThumbnail *)thumbnail;
- (void)expandAnimated: (BOOL) animated;

- (void) hideDisclosureButton;

@end

