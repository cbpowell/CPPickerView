//
//  TableViewController.h
//  PickerView
//
//  Created by Charles Powell on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CPPickerViewCell.h"

@interface TableViewController : UITableViewController <CPPickerViewCellDelegate, CPPickerViewCellDataSource>

@property (strong, nonatomic) NSMutableArray *settingsStorage;

@end