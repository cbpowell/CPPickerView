/**
 * Copyright (c) 2012 Charles Powell
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

//
//  CPPickerViewCell.h
//  PickerView
//


#import <UIKit/UIKit.h>
#import "CPPickerView.h"

@protocol CPPickerViewCellDataSource;
@protocol CPPickerViewCellDelegate;

@interface CPPickerViewCell : UITableViewCell <CPPickerViewDelegate, CPPickerViewDataSource>

@property (nonatomic, unsafe_unretained) id <CPPickerViewCellDataSource> dataSource;
@property (nonatomic, unsafe_unretained) id <CPPickerViewCellDelegate> delegate;
@property (nonatomic, copy) NSIndexPath *currentIndexPath;

@property (nonatomic, readonly) NSInteger selectedItem;
@property (nonatomic) BOOL showGlass;
@property (nonatomic) UIEdgeInsets peekInset;

// Handling
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
