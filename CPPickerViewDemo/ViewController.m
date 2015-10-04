//
//  ViewController.m
//  PickerView
//
//  Created by Fraerman Arkady on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController{
    NSArray* colors;
}

#pragma mark - Synthesizatoin

@synthesize numberLabel;
@synthesize dayLabel;




#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"View Usage";
	
    self.daysData = [[NSArray alloc] initWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil];
    
    colors = @[[UIColor redColor], [UIColor greenColor], [UIColor grayColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor orangeColor]];
    
    self.defaultPickerView = [[CPPickerView alloc] initWithFrame:CGRectMake(85, 30.0, 150, 40)];
    self.defaultPickerView.backgroundColor = [UIColor whiteColor];
    self.defaultPickerView.dataSource = self;
    self.defaultPickerView.delegate = self;
    self.defaultPickerView.allowSlowDeceleration = YES;
    [self.defaultPickerView reloadData];
    [self.view addSubview:self.defaultPickerView];
}

#pragma mark - CPPickerViewDataSource

- (NSInteger)numberOfItemsInPickerView:(CPPickerView *)pickerView
{
    return colors.count;
}


-(UIView*) pickerView:(CPPickerView *)pickerView viewForItem:(NSInteger)item reusingView:(UIView *)reusableView{
    UILabel* view = (UILabel*)reusableView;
    if (!view){
        view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 80)];
        view.textAlignment = NSTextAlignmentCenter;
    }
    view.backgroundColor = [colors objectAtIndex:item];
    view.text = [self pickerView:pickerView titleForItem:item];

    return view;
}

- (NSString *)pickerView:(CPPickerView *)pickerView titleForItem:(NSInteger)item
{
    return [NSString stringWithFormat:@"%i", item + 1];
}




#pragma mark - CPPickerViewDelegate

- (void)pickerView:(CPPickerView *)pickerView didSelectItem:(NSInteger)item
{
    self.numberLabel.text = [NSString stringWithFormat:@"%i", item + 1];
    self.numberLabel.textColor = [colors objectAtIndex:item];
}




#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}




- (void)viewDidUnload
{
    [self setNumberLabel:nil];
    [self setDayLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



@end
