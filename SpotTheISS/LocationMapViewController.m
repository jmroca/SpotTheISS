//
//  LocationMapViewController.m
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/20/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import "LocationMapViewController.h"
#import "DefineConst.h"
#import "ISSMapAnnotation.h"
#import "MKMapView+ZoomLevel.h"
#import <Twitter/Twitter.h>
#import "ImageUtils.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>


#define ZOOM_LEVEL 3



@interface LocationMapViewController () <MKMapViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSMutableArray *_locations;
    NSDictionary* currentLocation;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIImageView *imageSpot;


@property (weak) NSTimer* repeatingTimer;

@end

@implementation LocationMapViewController




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
    
    // bordes redondeados para imagen
    self.imageSpot.layer.cornerRadius = 15;
    self.imageSpot.layer.masksToBounds = YES;
    
    self.navigationController.navigationBarHidden = NO;
    
    
    [self getISSLocation];
    
    
}


-(void) getISSLocation
{
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:BaseURLString]];
    
    // 2
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client getPath:@"iss-now/"
         parameters:nil
            success:^(AFHTTPRequestOperation *operation, id JSON) {
                NSLog(@"response: %@",JSON);
                if(JSON)
                    currentLocation = [(NSDictionary *)JSON objectForKey:@"iss_position"];
                
                self.title = @"ISS Position";
                
                
                CLLocationDegrees latitude =
                [[currentLocation objectForKey:@"latitude"] doubleValue];
                CLLocationDegrees longitude =
                [[currentLocation objectForKey:@"longitude"] doubleValue];
                CLLocationCoordinate2D coordinate =
                CLLocationCoordinate2DMake(latitude, longitude);
                
                if (!_locations) {
                
                    ISSMapAnnotation* a = [[ISSMapAnnotation alloc] init];
                    
                    a.title = @"ISS";
                    a.coordinate = coordinate;
                
                    _locations = [NSArray arrayWithObject:a];
                
                    [self.mapView addAnnotations:_locations];
                    
                    CLLocationCoordinate2D center =
                    CLLocationCoordinate2DMake(a.coordinate.latitude, a.coordinate.longitude);
                    //MKCoordinateSpan span =
                    //MKCoordinateSpanMake(0.005334, 0.011834);
                    //MKCoordinateRegion regionToDisplay =
                    //MKCoordinateRegionMake(center, span);
                    //[self.mapView setRegion:regionToDisplay animated:NO];
                    
                    //[self.mapView setCenterCoordinate:center];
                     
                     [self.mapView setCenterCoordinate:center zoomLevel:3 animated:NO];
                    
                }
                else
                {
                    [UIView animateWithDuration:0.5 animations:^{
                        [[_locations lastObject] setCoordinate:coordinate];
                        [self.mapView setCenterCoordinate:coordinate];
                        }];
                }
                
                
            }
     
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving ISS Position"
                                                             message:[NSString stringWithFormat:@"%@",error]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                
            }
     ];
    
    
}


- (MKAnnotationView*)mapView:(MKMapView *)mapView
           viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[ISSMapAnnotation class]]) {
        static NSString *const kPinIdentifier = @"ISSStation";
        MKAnnotationView *view = [mapView                                                     dequeueReusableAnnotationViewWithIdentifier:kPinIdentifier];
        
        if (!view) {
            view = [[MKAnnotationView alloc]
                    initWithAnnotation:annotation
                    reuseIdentifier:kPinIdentifier];
            view.canShowCallout = YES;
            view.calloutOffset = CGPointMake(-5, 5);
        
            view.image = [UIImage imageNamed:@"spacestation_icon.png"];
        }
        
        return view;
    }
    return nil;
}


- (NSDictionary *)userInfo {
    return @{ @"StartDate" : [NSDate date] };
}

- (IBAction)cmdRefresh:(id)sender
{

    [self.repeatingTimer invalidate];
    
    NSTimer *timer = [NSTimer  scheduledTimerWithTimeInterval:3
                                                      target:self selector:@selector(getISSLocation)
                                                    userInfo:[self userInfo] repeats:YES];
    self.repeatingTimer = timer;
    

}


-(void) viewWillDisappear:(BOOL)animated
{
    [self.repeatingTimer invalidate];
    
}

#pragma mark - UIImagePickerController

// take a picture or select from photo album
- (IBAction)cmdTakePicture:(UISegmentedControl *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && sender.selectedSegmentIndex == 0)
    {
        // tomar la imagen de la camara
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([mediaTypes containsObject:(NSString *)kUTTypeImage]) {
            
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
            picker.allowsEditing = YES;
            
            if(IS_IPHONE)
                [self presentModalViewController:picker animated:YES];
            /*else if(IS_IPAD)
             {
             // presentarlo con uipopover
             self.popOverCamera = [[UIPopoverController alloc] initWithContentViewController:picker];
             [self.popOverCamera presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
             }*/
            
        }
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] && sender.selectedSegmentIndex == 1)
    {
        // tomar la imagen del album de fotos.
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        picker.allowsEditing = YES;
        
        if(IS_IPHONE)
            [self presentModalViewController:picker animated:YES];
        /*else if(IS_IPAD)
         {
         // presentarlo con uipopover
         self.popOverCamera = [[UIPopoverController alloc] initWithContentViewController:picker];
         [self.popOverCamera presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
         }*/
    }
    
    
}

- (void)dismissImagePicker
{
    
    if(IS_IPHONE)
        [self dismissModalViewControllerAnimated:YES];
    /*else if (IS_IPAD)
     [self.popOverCamera dismissPopoverAnimated:YES];
     */
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* thumbnail;
    
    // obtenemos imagen editada
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image)
        // obtenemos imagen original
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    if (image)
    {
        
        
        
        // reducimos a thumbnail la imagen, dependiendo de la orientacion
        if (image.imageOrientation == UIImageOrientationUp || image.imageOrientation == UIImageOrientationDown)
            thumbnail= [ImageUtils imageWithImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(132, 132)];
        else
            thumbnail= [ImageUtils imageWithImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(132, 132)];
        
        
        self.imageSpot.image = thumbnail;
        
        [self.mapView addSubview:self.imageSpot];
        
    }
    
    [self dismissImagePicker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissImagePicker];
}



// tweet text and image of ISS position and photo
- (IBAction)cmdTweet:(id)sender
{
    
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
    
    //Customize the tweet sheet here
    //Add a tweet message
    [tweetSheet setInitialText:@"International Space Station Spotted!!"];
    
    //Add an image
    [tweetSheet addImage:[ImageUtils generateImageFromView:self.mapView ]];
    
    
    //Set a blocking handler for the tweet sheet
    tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result){
        
        [self dismissModalViewControllerAnimated:YES];
    };
    
    //Show the tweet sheet!
    [self presentModalViewController:tweetSheet animated:YES];
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    [self.repeatingTimer invalidate];
    [self setImageSpot:nil];
    [self setMapView:nil];
    [super viewDidUnload];
}
@end
