//
//  SpotResultViewController.m
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/20/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import "SpotResultViewController.h"
#import "DefineConst.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ImageUtils.h"
#import <Twitter/Twitter.h>

@interface SpotResultViewController () < UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *txtReason;

@property (weak, nonatomic) IBOutlet UIImageView *imageSpot;



@end

@implementation SpotResultViewController

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
    self.imageSpot.layer.borderColor = [UIColor colorWithRed:64/255.f green:64/255.f blue:64/255.f alpha:1].CGColor;
    self.imageSpot.layer.borderWidth = 3;
    
    //bordes de campo de texto
    self.txtReason.layer.cornerRadius = 15;
    self.txtReason.layer.masksToBounds = YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            thumbnail= [ImageUtils imageWithImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(110, 85)];
        else
            thumbnail= [ImageUtils imageWithImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(85, 110)];
        
        
        self.imageSpot.image = thumbnail;
        
    }
    
    [self dismissImagePicker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissImagePicker];
}


- (IBAction)cmdQuestion:(id)sender {


}



- (IBAction)cmdCancel:(id)sender {

    [self.delegate recordSpotResultViewController:self recorded:NO ];

}



- (IBAction)cmdSave:(id)sender {


}


- (IBAction)cmdFacebook:(id)sender {

}


- (IBAction)cmdTwitter:(id)sender {


    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
    
    //Customize the tweet sheet here
    //Add a tweet message
    [tweetSheet setInitialText:[NSString stringWithFormat:@"%@", self.txtReason.text]];
    
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


- (void)viewDidUnload {
    [self setTxtReason:nil];
    [self setImageSpot:nil];
    [super viewDidUnload];
}
@end
