//
//  ViewController.h
//  MyMap
//
//  Created by Nikolay on 15.05.15.
//  Copyright (c) 2015 gng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>


- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender;


@end

