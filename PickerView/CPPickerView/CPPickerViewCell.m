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
//  CPPickerViewCell.m
//  PickerView
//


#import "CPPickerViewCell.h"

@interface CPPickerViewCell ()

@property (nonatomic, unsafe_unretained) CPPickerView *pickerView;

@end



@implementation CPPickerViewCell

@synthesize pickerView;
@synthesize dataSource, delegate;
@synthesize selectedItem, showGlass, peekInset;
@synthesize currentIndexPath = _currentIndexPath;

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
        self.pickerView.itemColor = [UIColor blackColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (NSIndexPath *)currentIndexPath {
    if (_currentIndexPath == nil) {
        _currentIndexPath = [(UITableView *)self.superview indexPathForCell:self];
    }
    return _currentIndexPath;
}

#pragma mark External

- (void)reloadData {
    [self.pickerView reloadData];
}

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self.pickerView selectItemAtIndex:index animated:animated];
}

- (NSInteger)selectedItem {
    return [self.pickerView selectedItem];
}

- (void)setShowGlass:(BOOL)doShowGlass {
    self.pickerView.showGlass = doShowGlass;
}

- (BOOL)showGlass {
    return self.pickerView.showGlass;
}

- (void)setPeekInset:(UIEdgeInsets)aPeekInset {
    self.pickerView.peekInset = aPeekInset;
}

- (UIEdgeInsets)peekInset {
    return self.pickerView.peekInset;
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
