//
//  MainMenuViewController.m
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/19/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SpotResultViewController.h"

@interface MainMenuViewController () <SpotResultViewControllerDelegate>

@end

@implementation MainMenuViewController

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
}

-(void) viewWillAppear:(BOOL)animated
{
    
    self.navigationController.navigationBarHidden = YES;
    
    self.navigationController.toolbarHidden = YES;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) recordSpotResultViewController:(SpotResultViewController *)sender recorded:(BOOL)result
{
    
    [self dismissModalViewControllerAnimated:YES];
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    if([segue.identifier isEqualToString:@"RecordSpot"])
    {
        [segue.destinationViewController setDelegate:self];
        
        
    }
    
    
    
    
}


@end
