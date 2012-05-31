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
    self.settingsStorage = [NSMutableArray arrayWithObjects:[NSMutableArray arrayWithObject:[NSNumber numberWithInt:0]], [NSMutableArray arrayWithObject:[NSNumber numberWithInt:1]], nil];
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
        cell = [[CPPickerViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier atIndexPath:indexPath];
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
    
    [cell selectItemAtIndex:[[[self.settingsStorage objectAtIndex:section] objectAtIndex:row] intValue] animated:NO];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Do Nothing
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
}


@end
