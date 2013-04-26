//
//  ConfigureSpotPassViewController.m
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/20/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import "ConfigureSpotPassViewController.h"

@interface ConfigureSpotPassViewController ()

@property (weak, nonatomic) IBOutlet UILabel *txtDateTime;

@property (weak, nonatomic) IBOutlet UILabel *txtDuration;


@property (weak, nonatomic) IBOutlet UISwitch *switchNotification;


@property (weak, nonatomic) IBOutlet UISwitch *switchCalendar;

@property (weak, nonatomic) IBOutlet UISwitch *switchPebble;

@end

@implementation ConfigureSpotPassViewController

@synthesize passTimeData = _passTimeData;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSString*) unixDateToLocaleDate:(double) unixTimeStamp
{
    
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setLocale:[NSLocale currentLocale]];
    [_formatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    
    return[_formatter stringFromDate:date];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.txtDateTime.text = [NSString stringWithFormat:@"%@", [self unixDateToLocaleDate:[[self.passTimeData objectForKey:@"risetime"] doubleValue]]];
    
    self.txtDuration.text = [NSString stringWithFormat:@"%d",(int)roundf([(NSNumber*)[self.passTimeData objectForKey:@"duration"] doubleValue]/60)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)scheduleNotificationWithInterval:(int)minutesBefore {
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [[NSDate date] addTimeInterval:(minutesBefore*10)];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = NSLocalizedString(@"Spot the ISS in 10 minutes.",nil);
                            
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
}


- (IBAction)cmdSave:(id)sender
{
    [self scheduleNotificationWithInterval:1];
    
}




- (void)viewDidUnload {
    [self setTxtDateTime:nil];
    [self setTxtDuration:nil];
    [self setSwitchNotification:nil];
    [self setSwitchCalendar:nil];
    [self setSwitchPebble:nil];
    [super viewDidUnload];
}
@end
