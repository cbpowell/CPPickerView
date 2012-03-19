//
//  CPPickerViewCell.h
//  PickerView
//
//  Created by Charles Powell on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPPickerView.h"

@protocol CPPickerViewCellDataSource;
@protocol CPPickerViewCellDelegate;

@interface CPPickerViewCell : UITableViewCell <CPPickerViewDelegate, CPPickerViewDataSource>

@property (nonatomic, unsafe_unretained) id <CPPickerViewCellDataSource> dataSource;
@property (nonatomic, unsafe_unretained) id <CPPickerViewCellDelegate> delegate;
@property (nonatomic, readonly) NSInteger selectedItem;
@property (nonatomic) BOOL showGlass;

- (void)reloadData;
- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated;

@end



@protocol CPPickerViewCellDataSource <NSObject>

- (NSInteger)numberOfItemsInPickerViewAtIndexPath:(NSIndexPath *)pickerPath;
- (NSString *)pickerViewAtIndexPath:(NSIndexPath *)pickerPath titleForItem:(NSInteger)item;

@end

@protocol CPPickerViewCellDelegate <NSObject>

- (void)pickerViewAtIndexPath:(NSIndexPath *)pickerPath didSelectItem:(NSInteger)item;

@end
