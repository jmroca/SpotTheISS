//
//  ConfigureSpotPassViewController.m
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/20/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import "ConfigureSpotPassViewController.h"
#import <EventKit/EventKit.h>

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

-(NSString*) unixDateToLocaleDateString:(double) unixTimeStamp
{
    
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setLocale:[NSLocale currentLocale]];
    [_formatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    
    return[_formatter stringFromDate:date];
}


-(NSDate*) unixDateToLocaleDate:(double) unixTimeStamp
{
    
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setLocale:[NSLocale currentLocale]];
    [_formatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    
    return[_formatter dateFromString:[_formatter stringFromDate:date]];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.txtDateTime.text = [NSString stringWithFormat:@"%@", [self unixDateToLocaleDateString:[[self.passTimeData objectForKey:@"risetime"] doubleValue]]];
    
    self.txtDuration.text = [NSString stringWithFormat:@"%d",(int)roundf([(NSNumber*)[self.passTimeData objectForKey:@"duration"] doubleValue]/60)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// schedule a local notification on the app
- (void)scheduleNotificationWithInterval:(int)minutesBefore {
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    
    if (localNotif == nil)
        return;
    
    // set fire date to the pass time date minus 10 minutes
    localNotif.fireDate = [[self unixDateToLocaleDate:[[self.passTimeData objectForKey:@"risetime"] doubleValue]] dateByAddingTimeInterval:(minutesBefore*-60)];
    
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = NSLocalizedString(@"Spot the ISS in 10 minutes!!",nil);
                            
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
    localNotif.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
}


- (IBAction)cmdSave:(id)sender
{
    // add event to calendar
    if(self.switchCalendar.on)
        [self addEventToCalendar];
    
    // add local notification
    if(self.switchNotification.on)
        [self scheduleNotificationWithInterval:10];
    
}


-(void)addEventToCalendar
{
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // the selector is available, so we must be on iOS 6 or newer
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    // display error message here
                    NSLog(@"Error: %@", error.description);
                }
                else if (!granted)
                {
                    // display access denied error message here
                    
                }
                else
                {
                    // access granted
                    EKEvent* event = [self createEventIn:eventStore];
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    
                }
            });
        }];
    }
    else
    {
        // this code runs in iOS 4 or iOS 5
        EKEvent* event = [self createEventIn:eventStore];
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        NSError *err;
        [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
    }

    
    
}


-(EKEvent*) createEventIn:(EKEventStore*) eventStore
{
    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
    event.title     = @"Spot The ISS";
    
    
    // set start and end datetimes, based on the pass time data
    event.startDate = [self unixDateToLocaleDate:[[self.passTimeData objectForKey:@"risetime"] doubleValue]];
    event.endDate = [event.startDate dateByAddingTimeInterval:[[self.passTimeData objectForKey:@"duration"] doubleValue]];
    
    // add alarms for two hours and 15 minutes before the pass time
    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -60.0f * 2]];
    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -15.0f]];
    
    return event;
    
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
