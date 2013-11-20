//
//  MapViewController.m
//  instamap
//
//  Created by Andrei Rozhkov on 20.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "MapViewController.h"
#import <JPSThumbnailAnnotation.h>

@interface MapViewController ()
{
}

@property (strong, nonatomic) MKPolyline *routeLine;
@property (strong, nonatomic) MKPolylineView *routeLineView;

@end

@implementation MapViewController

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
	// Do any additional setup after loading the view.
    
    CLLocationCoordinate2D coordinateArray[[self.thumbnails count]];
    
    if([self.thumbnails count] > 0)
    {
        for(int i=0; i<[self.thumbnails count]; i++)
        {
            JPSThumbnail *thumbnail = [self.thumbnails objectAtIndex:i];
            coordinateArray[i] = [thumbnail coordinate];
            thumbnail.disclosureBlock = ^{ [self pinInfo]; };
            [self.mapView addAnnotation:[[JPSThumbnailAnnotation alloc] initWithThumbnail:thumbnail]];
        }
    
        [self.mapView setCenterCoordinate:[[self.thumbnails objectAtIndex:0] coordinate] animated:YES];
        
        
        self.routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:[self.thumbnails count]];
        [self.mapView addOverlay:self.routeLine];
    }
}

- (void)pinInfo
{
    NSLog(@"pinInfo");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    return nil;
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    if(overlay == self.routeLine)
    {
        if(nil == self.routeLineView)
        {
            self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
            self.routeLineView.fillColor = [UIColor redColor];
            self.routeLineView.strokeColor = [UIColor redColor];
            self.routeLineView.lineWidth = 5;
        }
        return self.routeLineView;
    }
    return nil;
}

@end
