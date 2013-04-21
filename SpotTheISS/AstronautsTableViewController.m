//
//  AstronautsTableViewController.m
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/21/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import "AstronautsTableViewController.h"
#import "DefineConst.h"
#import "AFJSONRequestOperation.h"


@interface AstronautsTableViewController ()

@property (nonatomic, strong) NSArray* dataAstronauts;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end

@implementation AstronautsTableViewController

@synthesize dataAstronauts = _dataAstronauts;

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
    
    self.title = @"Astronauts @ ISS";
    
    self.navigationController.navigationBarHidden = NO;
    
    
    [self getDataAstronauts];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidUnload
{
    
    [self setActivityIndicator:nil];
    
}


-(void) getDataAstronauts
{
    
    [self.activityIndicator startAnimating];
    
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.open-notify.org/astros/v1/"]];
    
    // 2
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client getPath:@""
         parameters:nil
            success:^(AFHTTPRequestOperation *operation, id JSON) {
                if(JSON)
                    self.dataAstronauts = [(NSDictionary *)JSON objectForKey:@"people"];
                
                [self.activityIndicator stopAnimating];
                [self.tableView reloadData];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [self.activityIndicator stopAnimating];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                             message:[NSString stringWithFormat:@"%@",error]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                
            }
     ];
    
    
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
    if(!self.dataAstronauts)
        return 0;
    else
        return self.dataAstronauts.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AstronautCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary* data = [self.dataAstronauts objectAtIndex:indexPath.row];
    
    if (data) {
        
        cell.textLabel.text = [[self.dataAstronauts objectAtIndex:indexPath.row] objectForKey:@"name"];
        
        cell.detailTextLabel.text = [[self.dataAstronauts objectAtIndex:indexPath.row] objectForKey:@"craft"];
        
        
        cell.imageView.image = [UIImage imageNamed:@"twitter.png"];
        
        
        
        
        
    }
    
    return cell;
}



@end
