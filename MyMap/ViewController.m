//
//  ViewController.m
//  MyMap
//
//  Created by Nikolay on 15.05.15.
//  Copyright (c) 2015 gng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    BOOL isCurrentLocation;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@property (nonatomic, strong) CLLocationManager * locationManager;


@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *annPoints;


@end


@implementation ViewController

- (void)firstLunch {
    
    NSString * ver = [[UIDevice currentDevice] systemVersion];
    
    if ([ver integerValue] >= 8) {
        [self.locationManager requestAlwaysAuthorization];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstLunch"];
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    isCurrentLocation = NO;
    self.mapView.showsUserLocation = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //[self.locationManager startUpdatingLocation];
    
    BOOL isFirstLunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstLunch"];
    if (!isFirstLunch) {
        [self firstLunch];
    }
    
    
    self.annPoints = [[NSMutableArray alloc] init];
  //  [self.annPoints addObject:@"aaa"];
  //  [self.annPoints addObject:@"bbb"];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MKMapViewDelegate



- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    
    if (fullyRendered) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)setupMapView: (CLLocationCoordinate2D) coord {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 5000, 5000);
    
    [self.mapView setRegion:region animated:YES];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if (![annotation isKindOfClass:MKUserLocation.class]) {
        
        MKAnnotationView * annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
        
        annView.canShowCallout = NO;
        annView.image = [UIImage imageNamed:@"marker.png"];
        
        [annView addSubview:[self getCalloutView:annotation.title]];
        
        return annView;
    }
    
    return nil;
}

- (UIView *)getCalloutView: (NSString *) title {
    
    UIView * callView = [[UIView alloc] initWithFrame:CGRectMake(-90, -90, 200, 80)];
    callView.backgroundColor = [UIColor whiteColor];
    callView.tag = 1000;
    callView.alpha = 0;
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 190, 70)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:12];
    label.text = title;
    
    [callView addSubview:label];
    
    return callView;
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if (![view.annotation isKindOfClass:MKUserLocation.class]) {
        
        for (UIView * subView in view.subviews) {
            
            if (subView.tag == 1000) {

                [self setupMapView: view.annotation.coordinate];

                subView.alpha = 1;
                
            }
            
        }
    }
    
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    for (UIView * subView in view.subviews) {
        
        if (subView.tag == 1000) {
            subView.alpha = 0;
        }
        
    }
    
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    //NSLog(@"locationManager - %f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    if (!isCurrentLocation) {
        isCurrentLocation = YES;
        
        [self setupMapView: newLocation.coordinate];
    }
    
    
}

#pragma mark -GestureRecognizer

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
        
        
        CLLocationCoordinate2D coordScreenPoint = [self.mapView convertPoint:[sender locationInView:self.mapView] toCoordinateFromView:self.mapView];
        
        CLGeocoder * geocoder = [[CLGeocoder alloc] init];
        
        CLLocation * tapLocation = [[CLLocation alloc] initWithLatitude:coordScreenPoint.latitude longitude:coordScreenPoint.longitude];
        
        [geocoder reverseGeocodeLocation:tapLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            
            CLPlacemark * place = [placemarks objectAtIndex:0];
            
            //NSLog(@"place %@", place.addressDictionary);
            
            NSString * addressString = [NSString stringWithFormat:@"Город - %@\nУлица - %@\nИндекс - %@",
                                        [place.addressDictionary valueForKey:@"City"],
                                        [place.addressDictionary valueForKey:@"Street"],
                                        [place.addressDictionary valueForKey:@"ZIP"]];
            
            /*
             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Address" message:addressString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             
             [alert show];
             */
            
            MKPointAnnotation * annotation = [[MKPointAnnotation alloc] init];
            annotation.title = addressString;
            annotation.coordinate = coordScreenPoint;

            
            [self.annPoints addObject:addressString];
        
            [self.tableView reloadData];
            
            [self.mapView addAnnotation:annotation];
            
            
            
            
        }];
        
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"UIGestureRecognizerStateChanged");
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
        
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.annPoints count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    
    UILabel * label = [[UILabel alloc] initWithFrame: CGRectMake(10, 0, cell.frame.size.width, cell.frame.size.height)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:12];
    label.text = [self.annPoints objectAtIndex:indexPath.row];
    
    [cell addSubview:label];
    
    return cell;
}


@end
