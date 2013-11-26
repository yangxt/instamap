//
//  MapSearchViewController.m
//  instamap
//
//  Created by Andrei Rozhkov on 20.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "MapSearchViewController.h"
#import "MyAnnotation.h"
#import "PlacesViewController.h"

@interface MapSearchViewController ()
{
    CLLocationCoordinate2D droppedAt;
}
@end

@implementation MapSearchViewController

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
    if([self.latitude length] == 0 && [self.longitude length] == 0)
        droppedAt = CLLocationCoordinate2DMake(55.733771, 37.587937);
    else
        droppedAt = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(droppedAt, 700, 700);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    MyAnnotation *myPin = [[MyAnnotation alloc] initWithCoordinate:droppedAt];
    myPin.title = self.mytitle;
    myPin.subtitle = self.mysubtitle;
    [self.mapView addAnnotation:myPin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation {
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"];
    } else {
        pin.annotation = annotation;
    }
    pin.animatesDrop = YES;
    pin.draggable = YES;
    pin.canShowCallout = YES;
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        droppedAt = annotationView.annotation.coordinate;
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"places"])
    {
        PlacesViewController *places = [segue destinationViewController];
        [places setLat:[NSString stringWithFormat:@"%f", droppedAt.latitude]];
        [places setLng:[NSString stringWithFormat:@"%f", droppedAt.longitude]];
    }
}
@end
