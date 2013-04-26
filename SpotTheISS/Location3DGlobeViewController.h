//
//  Location3DGlobeViewController.h
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/24/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhirlyGlobeComponent.h"


@interface Location3DGlobeViewController : UIViewController  <WhirlyGlobeViewControllerDelegate>
{
    WhirlyGlobeViewController *globeViewC;
    
    
    
}

@property (weak, nonatomic) IBOutlet UIView *globeView;

@end
