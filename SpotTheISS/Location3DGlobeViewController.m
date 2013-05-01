//
//  Location3DGlobeViewController.m
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/24/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import "Location3DGlobeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import <CoreLocation/CoreLocation.h>
#import "DefineConst.h"
#import "ImageUtils.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Twitter/Twitter.h>



@interface Location3DGlobeViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{

// These represent a group of objects we've added to the globe.
// This is how we track them for removal
WGComponentObject *screenMarkersObj;
WGComponentObject *markersObj;
WGComponentObject *screenLabelsObj;
WGComponentObject *labelsObj;
NSArray *vecObjects;

// The view we're using to track a selected object
WGViewTracker *selectedViewTrack;
NSDictionary* currentLocation;

// marker for the ISS position
WGMarker* isspos;

}

@property (weak) NSTimer* repeatingTimer;

@property (weak, nonatomic) IBOutlet UIImageView *imageSpot;

// Change what we're showing based on the Configuration
- (void)changeGlobeContents;

@end



@implementation Location3DGlobeViewController


- (void)dealloc
{
    // This should release the globe view
    if (globeViewC)
    {
        [globeViewC.view removeFromSuperview];
        [globeViewC removeFromParentViewController];
        globeViewC = nil;
        
        [EAGLContext setCurrentContext:nil];
    }
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
                
                
                if (!isspos) {
                    
                    NSMutableArray *markers = [NSMutableArray array];
                    
                    isspos = [[WGMarker alloc] init];
                    isspos.image = [UIImage imageNamed:@"spacestation_icon"];
                    isspos.loc = WGCoordinateMakeWithDegrees(longitude,latitude);
                    isspos.size = CGSizeMake(40, 40);
                    [markers addObject:isspos];
                    
                    
                    screenMarkersObj = [globeViewC addScreenMarkers:markers];
                    
                    [globeViewC animateToPosition:isspos.loc time:1.0];
                    
                    
                }
                else
                {
                    [globeViewC removeObject:screenMarkersObj];
                    screenMarkersObj = nil;
                    NSMutableArray *markers = [NSMutableArray array];
                    isspos.loc = WGCoordinateMakeWithDegrees(longitude,latitude);
                    
                    [markers addObject:isspos];
                    
                    screenMarkersObj = [globeViewC addScreenMarkers:markers];
                    
                    [globeViewC animateToPosition:isspos.loc time:1.0];
                    
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




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    // bordes redondeados para imagen
    self.imageSpot.layer.cornerRadius = 15;
    self.imageSpot.layer.masksToBounds = YES;
    
    
    // Create an empty globe view controller and hook it in to our view hiearchy
    globeViewC = [[WhirlyGlobeViewController alloc] init];
    [self.globeView addSubview:globeViewC.view];
    globeViewC.view.frame = self.globeView.bounds;
    [self addChildViewController:globeViewC];
    
    // Set the background color for the globe
    globeViewC.clearColor = [UIColor blackColor];
    
    // This will get us taps and such
    globeViewC.delegate = self;
    
    // Start up over San Francisco
    [globeViewC animateToPosition:WGCoordinateMakeWithDegrees( -90.230759, 15.783471) time:1.0];
    
    // Zoom in a bit
    globeViewC.height = 0.9;
    
    // We'll pick default colors for the labels
    UIColor *screenLabelColor = [UIColor whiteColor];
    UIColor *screenLabelBackColor = [UIColor clearColor];
    UIColor *labelColor = [UIColor whiteColor];
    UIColor *labelBackColor = [UIColor clearColor];
    // And for the vectors to stand out
    UIColor *vecColor = [UIColor whiteColor];
    float vecWidth = 1.0;
    
    // Set up the base layer
    // This is the static image set, included with the app, built with ImageChopper
    [globeViewC addSphericalEarthLayerWithImageSet:@"lowres_wtb_info"];
        
         
    // Set up some defaults for display
    NSDictionary *screenLabelDesc = [NSDictionary dictionaryWithObjectsAndKeys:
                                     screenLabelColor,kWGTextColor,
                                     screenLabelBackColor,kWGBackgroundColor,
                                     nil];
    [globeViewC setScreenLabelDesc:screenLabelDesc];
    NSDictionary *labelDesc = [NSDictionary dictionaryWithObjectsAndKeys:
                               labelColor,kWGTextColor,
                               labelBackColor,kWGBackgroundColor,
                               nil];
    [globeViewC setLabelDesc:labelDesc];
    NSDictionary *vectorDesc = [NSDictionary dictionaryWithObjectsAndKeys:
                                vecColor,kWGColor,
                                [NSNumber numberWithFloat:vecWidth],kWGVecWidth,
                                nil];
    [globeViewC setVectorDesc:vectorDesc];
    
    // Restrict the min and max zoom
    //    [globeViewC setZoomLimitsMin:1.2 max:1.5];
    
    // Bring up things based on what's turned on
    [self performSelector:@selector(changeGlobeContents) withObject:nil afterDelay:0.0];
    
    [self getISSLocation];
    
    [self.repeatingTimer invalidate];
    
    NSTimer *timer = [NSTimer  scheduledTimerWithTimeInterval:3
                                                       target:self selector:@selector(getISSLocation)
                                                     userInfo:[self userInfo] repeats:YES];
    self.repeatingTimer = timer;
    
    
}

- (NSDictionary *)userInfo {
    return @{ @"StartDate" : [NSDate date] };
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.repeatingTimer invalidate];
    
}

- (void)viewDidUnload
{
    [self setGlobeView:nil];
    [self setImageSpot:nil];
    [super viewDidUnload];
    
    [self.repeatingTimer invalidate];
    
    // This should release the globe view
    if (globeViewC)
    {
        [globeViewC.view removeFromSuperview];
        [globeViewC removeFromParentViewController];
        globeViewC = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Data Display


// Look at the configuration controller and decide what to turn off or on
- (void)changeGlobeContents
{
    
    globeViewC.keepNorthUp = YES;
    globeViewC.pinchGesture = YES;
    globeViewC.rotateGesture = YES;
    
    // Update rendering hints
    NSMutableDictionary *hintDict = [NSMutableDictionary dictionary];
    [hintDict setObject:[NSNumber numberWithBool:NO] forKey:kWGRenderHintCulling];
    [hintDict setObject:[NSNumber numberWithBool:NO] forKey:kWGRenderHintZBuffer];
    [globeViewC setHints:hintDict];
}

#pragma mark - Whirly Globe Delegate

// Build a simple selection view to draw over top of the globe
- (UIView *)makeSelectionView:(NSString *)msg
{
    float fontSize = 32.0;
    float marginX = 32.0;
    
    // Make a label and stick it in as a view to track
    // We put it in a top level view so we can center it
    UIView *topView = [[UIView alloc] initWithFrame:CGRectZero];
    topView.alpha = 0.8;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    [topView addSubview:backView];
    topView.clipsToBounds = NO;
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [backView addSubview:testLabel];
    testLabel.font = [UIFont systemFontOfSize:fontSize];
    testLabel.textColor = [UIColor whiteColor];
    testLabel.backgroundColor = [UIColor clearColor];
    testLabel.text = msg;
    CGSize textSize = [testLabel.text sizeWithFont:testLabel.font];
    testLabel.frame = CGRectMake(marginX/2.0,0,textSize.width,textSize.height);
    testLabel.opaque = NO;
    backView.layer.cornerRadius = 5.0;
    backView.backgroundColor = [UIColor colorWithRed:0.0 green:102/255.0 blue:204/255.0 alpha:1.0];
    backView.frame = CGRectMake(-(textSize.width)/2.0,-(textSize.height)/2.0,textSize.width+marginX,textSize.height);
    
    return topView;
}

// User selected something
- (void)globeViewController:(WhirlyGlobeViewController *)viewC didSelect:(NSObject *)selectedObj
{
    // If we've currently got a selected view, get rid of it
    if (selectedViewTrack)
    {
        [globeViewC removeViewTrackForView:selectedViewTrack.view];
        selectedViewTrack = nil;
    }
    
    WGCoordinate loc;
    NSString *msg = nil;
    
    if ([selectedObj isKindOfClass:[WGMarker class]])
    {
        WGMarker *marker = (WGMarker *)selectedObj;
        loc = marker.loc;
        msg = [NSString stringWithFormat:@"Marker: Unknown"];
    } else if ([selectedObj isKindOfClass:[WGScreenMarker class]])
    {
        WGScreenMarker *screenMarker = (WGScreenMarker *)selectedObj;
        loc = screenMarker.loc;
        msg = [NSString stringWithFormat:@"Screen Marker: Unknown"];
    } else if ([selectedObj isKindOfClass:[WGLabel class]])
    {
        WGLabel *label = (WGLabel *)selectedObj;
        loc = label.loc;
        msg = [NSString stringWithFormat:@"Label: %@",label.text];
    } else if ([selectedObj isKindOfClass:[WGScreenLabel class]])
    {
        WGScreenLabel *screenLabel = (WGScreenLabel *)selectedObj;
        loc = screenLabel.loc;
        msg = [NSString stringWithFormat:@"Screen Label: %@",screenLabel.text];
    } else if ([selectedObj isKindOfClass:[WGVectorObject class]])
    {
        WGVectorObject *vecObj = (WGVectorObject *)selectedObj;
        loc = [vecObj largestLoopCenter];
        msg = [NSString stringWithFormat:@"Vector"];
    } else
        // Don't know what it is
        return;
    
    // Build the selection view and hand it over to the globe to track
    selectedViewTrack = [[WGViewTracker alloc] init];
    selectedViewTrack.loc = loc;
    selectedViewTrack.view = [self makeSelectionView:msg];
    [globeViewC addViewTracker:selectedViewTrack];
}

// User didn't select anything, but did tap
- (void)globeViewController:(WhirlyGlobeViewController *)viewC didTapAt:(WGCoordinate)coord
{
    // Just clear the selection
    if (selectedViewTrack)
    {
        [globeViewC removeViewTrackForView:selectedViewTrack.view];
        selectedViewTrack = nil;        
    }
}


- (void)globeViewController:(WhirlyGlobeViewController *)viewC layerDidLoad:(WGViewControllerLayer *)layer
{
    NSLog(@"Spherical Earth Layer loaded.");
}

#pragma mark - UIImagePickerController

// tomar o seleccionar una foto
- (IBAction)cmdTakePicture:(UISegmentedControl *)sender
{
    
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
        
        [self.globeView addSubview:self.imageSpot];
        
    }
    
    [self dismissImagePicker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissImagePicker];
}



- (UIImage*)snapshot:(UIView*)eaglview
{
    GLint backingWidth1, backingHeight1;
    
    // Bind the color renderbuffer used to render the OpenGL ES view
    // If your application only creates a single color renderbuffer which is already bound at this point,
    // this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
    // Note, replace "_colorRenderbuffer" with the actual name of the renderbuffer object defined in your class.
    //glBindRenderbuffer(GL_RENDERBUFFER, glIsRenderbuffer);
    
    // Get the size of the backing CAEAGLLayer
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth1);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight1);
    
    NSInteger x = 0, y = 0, width = backingWidth1, height = backingHeight1;
    NSInteger dataLength = width * height * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    NSInteger widthInPoints, heightInPoints;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        CGFloat scale = eaglview.contentScaleFactor;
        widthInPoints = width / scale;
        heightInPoints = height / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
    }
    else {
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        widthInPoints = width;
        heightInPoints = height;
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
    }
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    return image;

}

// tweet text and image of ISS position and photo
- (IBAction)cmdTweet:(id)sender
{
    
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
    
    //Customize the tweet sheet here
    //Add a tweet message
    [tweetSheet setInitialText:@"International Space Station Spotted!!"];
    
    //Add an image
    //[tweetSheet addImage:[self snapshot:globeViewC.view]];
    
    if (self.imageSpot.image != nil)
        [tweetSheet addImage:self.imageSpot.image];
    
    //Set a blocking handler for the tweet sheet
    tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result){
        
        [self dismissModalViewControllerAnimated:YES];
    };
    
    //Show the tweet sheet!
    [self presentModalViewController:tweetSheet animated:YES];
    
    
}



@end
