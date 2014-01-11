//
//  TableViewController.m
//  PickerView
//
//  Created by Charles Powell on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TableViewController.h"

#import "CPPickerViewCell.h"

@interface TableViewController ()

@end

@implementation TableViewController

@synthesize settingsStorage;

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
    
    self.title = @"Table Usage";
    NSArray *section1 = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:0], nil];
    NSArray *section2 = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:1], nil];
    self.settingsStorage = [NSMutableArray arrayWithObjects:section1, section2, nil];
    
    [self setLabelTextForSection:0 forItem:0];
    [self setLabelTextForSection:1 forItem:1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.settingsStorage = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setLabelTextForSection:(NSUInteger)section forItem:(NSUInteger)item
{
    switch (section) {
        case 0:
            // Section 1
            self.sectionOneLabel.text = [NSString stringWithFormat:@"Section 1: Option %i", item + 1];
            break;
            
        case 1:
            // Section 2
            self.sectionTwoLabel.text = [NSString stringWithFormat:@"Section 2: %i", item + 1];
            break;
            
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Section %i", section + 1];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CPPickerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CPPickerViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = @"Multi-option picker";
    
    cell.dataSource = self;
    cell.delegate = self;
    cell.currentIndexPath = indexPath;
    
    [cell reloadData];
    
    
    // Configure/Reconfigure
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 1) {
        cell.showGlass = YES;
        cell.peekInset = UIEdgeInsetsMake(0, 35, 0, 35);
    }
    
    NSArray *sectionStorage = [self.settingsStorage objectAtIndex:section];
    NSUInteger setting = [[sectionStorage objectAtIndex:row] unsignedIntegerValue];
    
    [cell setSelectedItem:setting animated:NO];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CPPickerViewCell DataSource

- (NSInteger)numberOfItemsInPickerViewAtIndexPath:(NSIndexPath *)pickerPath {
    if (pickerPath.section == 0) {
        return 4;
    }
    
    if (pickerPath.section == 1) {
        return 10;
    }
    
    return 0;
}

- (NSString *)pickerViewAtIndexPath:(NSIndexPath *)pickerPath titleForItem:(NSInteger)item {
    if (pickerPath.section == 0) {
        return [NSString stringWithFormat:@"Option %i", item + 1];
    }
    
    if (pickerPath.section == 1) {
        return [NSString stringWithFormat:@"%i", item + 1];
    }
    
    return nil;
}

#pragma mark - CPPickerViewCell Delegate

- (void)pickerViewAtIndexPath:(NSIndexPath *)pickerPath didSelectItem:(NSInteger)item {
    [[self.settingsStorage objectAtIndex:pickerPath.section] replaceObjectAtIndex:pickerPath.row withObject:[NSNumber numberWithInt:item]];
    
    [self setLabelTextForSection:pickerPath.section forItem:item];
}


@end
