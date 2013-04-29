//
//  PassTimesTableViewController.m
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/19/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import "PassTimesTableViewController.h"
#import "DefineConst.h"
#import "AFJSONRequestOperation.h"
#import "AppDelegate.h"
#import "ConfigureSpotPassViewController.h"
#import "UIImageView+AFNetworking.h"

@interface PassTimesTableViewController ()

@property (nonatomic, strong) NSArray* dataPassTimes;

@property (nonatomic, strong) NSArray* dataWeather;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end


@implementation PassTimesTableViewController

@synthesize dataPassTimes = _dataPassTimes;
@synthesize dataWeather = _dataWeather;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    //self.tableView.backgroundColor = [UIColor grayColor];
    
    // activar deteccion de ubicacion via CoreLocation
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.locationManager startUpdatingLocation];

    
    
    // suscribirse a la notificacion cuando el app regresa a foreground.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activateLocationUpdating) name:UIApplicationDidBecomeActiveNotification object:nil];

    
    self.title = @"Next Pass Times";
    
    self.navigationController.navigationBarHidden = NO;
    
    // launch query of pass times for the current location.
    [self getDataPassTimes];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // activar deteccion de ubicacion via CoreLocation
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.locationManager startUpdatingLocation];

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // desactivar deteccion de ubicacion via CoreLocation
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.locationManager stopUpdatingLocation];
    
    NSLog(@"Location Stopped");
    
}

-(void) viewDidUnload
{
    [self setActivityIndicator:nil];
    
    // desactivar deteccion de ubicacion via CoreLocation
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.locationManager stopUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

-(void) activateLocationUpdating
{
    // activar deteccion de ubicacion via CoreLocation
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.locationManager startUpdatingLocation];
    
}



-(void) getDataPassTimes
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.activityIndicator startAnimating];
    
    NSLog(@"Parametros: %@, %@, %@",[NSString stringWithFormat:@"%+.6f",appDelegate.currentLocation.coordinate.latitude],
          [NSString stringWithFormat:@"%+.6f",appDelegate.currentLocation.coordinate.longitude],
          [NSString stringWithFormat:@"%+.6f",appDelegate.currentLocation.altitude]);
    
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:BaseURLString]];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                    [NSString stringWithFormat:@"%f",appDelegate.currentLocation.coordinate.latitude],
                                                                    [NSString stringWithFormat:@"%f",appDelegate.currentLocation.coordinate.longitude],
                                                                    [NSString stringWithFormat:@"%f",appDelegate.currentLocation.altitude],
                                                                    
                                                                    @"5",nil]
                                                           forKeys:[NSArray arrayWithObjects:@"lat",@"lon",@"alt",@"n",nil]];
    
    // 2
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client getPath:@"iss/"
         parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id JSON) {
                if(JSON)
                {
                    self.dataPassTimes = [(NSDictionary *)JSON objectForKey:@"response"];
                    NSLog(@"Message y Latitud: %@ , %@",[(NSDictionary *)JSON objectForKey:@"message"],
                          [[(NSDictionary *)JSON objectForKey:@"request"] objectForKey:@"latitude"]);
                }
                [self getDataWeather];
                [self.activityIndicator stopAnimating];
                [self.tableView reloadData];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [self.activityIndicator stopAnimating];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving ISS Pass Times"
                                                             message:[NSString stringWithFormat:@"%@",error]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                
            }
     ];
    
    
}

-(void) getDataWeather
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.activityIndicator startAnimating];
    
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:BaseWWURLString]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                    [NSString stringWithFormat:@"%f,%f",appDelegate.currentLocation.coordinate.latitude,appDelegate.currentLocation.coordinate.longitude],
                                                                    @"json",@"5",@"no",WorldWeatherAPIKey,nil]
                                                           forKeys:[NSArray arrayWithObjects:@"q",@"format",@"num_of_days",@"cc",@"key",nil]];
    
    // 2
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client getPath:@"weather.ashx"
         parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id JSON) {
                if(JSON)
                    self.dataWeather = [[(NSDictionary *)JSON objectForKey:@"data"] objectForKey:@"weather"];
                
                [self.activityIndicator stopAnimating];
                [self.tableView reloadData];
                
                if(self.dataWeather)
                    NSLog(@"Weather: %@ %@", [[self.dataWeather lastObject] objectForKey:@"date"], [[self.dataWeather lastObject] objectForKey:@"weatherCode"]);
            
            }
     
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [self.activityIndicator stopAnimating];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather Data"
                                                             message:[NSString stringWithFormat:@"%@",error]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                
            }
     ];
    
    
}

// convert unix timestamp (echo timestamp) to local date time.
-(NSString*) unixDateToLocaleDate:(double) unixTimeStamp withFormat:(NSString*) format
{
    
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setLocale:[NSLocale currentLocale]];
    [_formatter setDateFormat:format];
    
    return[_formatter stringFromDate:date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(!self.dataPassTimes)
        return 0;
    else
        return self.dataPassTimes.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PassTimesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary* data = [self.dataPassTimes objectAtIndex:indexPath.row];
    
    if (data) {
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [self unixDateToLocaleDate:[[data objectForKey:@"risetime"] doubleValue]
                                                                                withFormat:@"dd/MM/yyyy HH:mm"]];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Duration (min): %d",(int)roundf([(NSNumber*)[data objectForKey:@"duration"] doubleValue]/60)];
        
        
        // obtain weather info for the pass date
        for (NSDictionary* dateInfo in self.dataWeather) {
            
            if ([[dateInfo objectForKey:@"date"] isEqualToString:[self unixDateToLocaleDate:[[data objectForKey:@"risetime"] doubleValue]
                                                                                 withFormat:@"yyyy-MM-dd"]])
            {
                // use the weather service icon to set the cell image.
                __weak UITableViewCell *weakCell = cell;
                
                [cell.imageView setImageWithURLRequest:[[NSURLRequest alloc]
                                                        initWithURL:[NSURL URLWithString:[[[dateInfo objectForKey:@"weatherIconUrl"] lastObject] objectForKey:@"value"]]]
                                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                                   weakCell.imageView.image = image;
                                                   
                                                   [weakCell setNeedsLayout];
                                                   
                                               }
                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                                   
                                               }];

                
                break;
            }
        }
        
            
            
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     ConfigureSpotPassViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfigurePassTime"];
    
    detailViewController.passTimeData = [self.dataPassTimes objectAtIndex:indexPath.row];
    
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
    
}


- (IBAction)cmdRefresh:(id)sender
{
    [self getDataPassTimes];
}


@end
