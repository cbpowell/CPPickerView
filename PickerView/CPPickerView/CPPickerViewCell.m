//
//  CPPickerViewCell.m
//  PickerView
//
//  Created by Charles Powell on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPPickerViewCell.h"

@interface CPPickerViewCell ()

@property (nonatomic, unsafe_unretained) CPPickerView *pickerView;
@property (nonatomic, readonly) NSIndexPath *currentIndexPath;

@end



@implementation CPPickerViewCell

@synthesize pickerView;
@synthesize dataSource, delegate;
@synthesize selectedItem, showGlass;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CPPickerView *newPickerView = [[CPPickerView alloc] initWithFrame:CGRectMake(192, 8, 112, 30)];
        [self addSubview:newPickerView];
        self.pickerView = newPickerView;
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.itemFont = [UIFont boldSystemFontOfSize:14];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSIndexPath *)currentIndexPath {
    return [(UITableView *)self.superview indexPathForCell: self];
}

#pragma mark External

- (void)reloadData {
    [self.pickerView reloadData];
}

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self.pickerView selectItemAtItem:index animated:animated];
}

- (NSInteger)selectedItem {
    return [self.pickerView selectedItem];
}

- (void)setShowGlass:(BOOL)doShowGlass {
    self.pickerView.showGlass = doShowGlass;
}

#pragma mark CPPickerView Delegate

- (void)pickerView:(CPPickerView *)pickerView didSelectItem:(NSInteger)item {
    if ([self.delegate respondsToSelector:@selector(pickerViewAtIndexPath:didSelectItem:)]) {
        [self.delegate pickerViewAtIndexPath:self.currentIndexPath didSelectItem:item];
    }
}

#pragma mark CPPickerView Datasource

- (NSInteger)numberOfItemsInPickerView:(CPPickerView *)pickerView {
    NSInteger numberOfItems = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInPickerViewAtIndexPath:)]) {
        numberOfItems = [self.dataSource numberOfItemsInPickerViewAtIndexPath:self.currentIndexPath];
    }
    
    return numberOfItems;
}

- (NSString *)pickerView:(CPPickerView *)pickerView titleForItem:(NSInteger)item {
    NSString *title = nil;
    if ([self.dataSource respondsToSelector:@selector(pickerViewAtIndexPath:titleForItem:)]) {
        title = [self.dataSource pickerViewAtIndexPath:self.currentIndexPath titleForItem:item];
    }
    
    return title;
}

#pragma mark Custom getters/setters

@end
