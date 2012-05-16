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

/**
 * Based heavily on AFPickerView by Fraerman Arkady
 * https://github.com/arkichek/AFPickerView
 */

//
//  CPPickerView.m
//

#import "CPPickerView.h"

#pragma mark - CPPickerView

@interface CPPickerContent : UIView

@property (nonatomic, unsafe_unretained) CPPickerView *pickerView;

@end

@interface CPPickerView ()

@property (nonatomic, strong) id <UIScrollViewDelegate> privateDelegate;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *glassImage;
@property (nonatomic, strong) UIImage *shadowImage;
@property (nonatomic, unsafe_unretained) CPPickerContent *content;

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) NSUInteger itemCount;
@property (nonatomic, strong) NSMutableArray *items;

- (void)setup;
- (void)determineCurrentItem;
- (void)tileViews;

@end

#pragma mark - CPPickerPrivateDelegate

@interface CPPickerPrivateDelegate : NSObject <UIScrollViewDelegate>

@property (nonatomic, unsafe_unretained) CPPickerView *pickerView;

@end



@implementation CPPickerPrivateDelegate

@synthesize pickerView;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.pickerView tileViews];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.pickerView determineCurrentItem];
}
@end



#pragma mark - CPPickerItem

@implementation CPPickerContent

@synthesize pickerView;

- (void)drawRect:(CGRect)rect {
    
    // Draw appropriate items
    [self.pickerView.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj != [NSNull null]) {
            CGRect textRect = CGRectMake(self.pickerView.frame.size.width * idx, ((int)self.pickerView.bounds.size.height/2 - (int)self.pickerView.itemFont.lineHeight/2), self.pickerView.bounds.size.width, self.pickerView.frame.size.height);
            [(NSString *)obj drawInRect:textRect withFont:self.pickerView.itemFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
        }
    }];
    
    //[super drawRect:rect];
}

@end

@implementation CPPickerView

@synthesize privateDelegate;
@synthesize pickerDataSource;
@synthesize pickerDelegate;

@synthesize itemCount, currentIndex;
@synthesize items;

@synthesize glassImage, backgroundImage, shadowImage;
@synthesize content;
@synthesize selectedItem = _selectedItem;
@synthesize itemFont = _itemFont;
@synthesize itemColor = _itemColor;
@synthesize showGlass;
//@synthesize peekInset;

#pragma mark - Custom getters/setters

- (void)setSelectedItem:(NSUInteger)selectedItem
{
    if (selectedItem >= self.itemCount)
        return;
    
    currentIndex = selectedItem;
    [self scrollToIndex:currentIndex animated:NO];
}

- (void)setItemFont:(UIFont *)itemFont
{
    if (![itemFont isEqual:_itemFont]) {
        _itemFont = itemFont;
        [self setNeedsDisplay];
    }
}

- (void)setItemColor:(UIColor *)itemColor
{
    if (![itemColor isEqual:_itemColor]) {
        _itemColor = itemColor;
        [self setNeedsDisplay];
    }
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Setup
        [self setup];
        
        // Images
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
            self.backgroundImage = [[UIImage imageNamed:@"wheelBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
            self.glassImage = [[UIImage imageNamed:@"stretchableGlass"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
        } else {
            self.backgroundImage = [[UIImage imageNamed:@"wheelBackground"] stretchableImageWithLeftCapWidth:0 topCapHeight:5];
            self.glassImage = [[UIImage imageNamed:@"stretchableGlass"]  stretchableImageWithLeftCapWidth:1 topCapHeight:0];
        }
        self.shadowImage = [UIImage imageNamed:@"shadowOverlay"];
        
        // Rounded borders
        self.layer.cornerRadius = 3.0f;
        self.layer.borderColor = [UIColor colorWithWhite:0.15 alpha:1.0].CGColor;
        self.layer.borderWidth = 1.0f;
    }
    return self;
}



- (void)setup
{
    // Scrollview settings
    self.clipsToBounds = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled = YES;
    self.scrollsToTop = NO;
    self.opaque = YES;
    self.backgroundColor = [UIColor clearColor];
    
    // Content view
    CPPickerContent *newContent = [[CPPickerContent alloc] initWithFrame:self.bounds];
    [self addSubview:newContent];
    self.content = newContent;
    self.content.pickerView = self;
    self.content.backgroundColor = [UIColor clearColor];
    
    // Private delegate
    self.privateDelegate = [[CPPickerPrivateDelegate alloc] init];
    self.delegate = self.privateDelegate;
    [(CPPickerPrivateDelegate *)self.privateDelegate setPickerView:self];
    
    // Item tracker
    self.items = [NSMutableArray array];
    
    _itemFont = [UIFont boldSystemFontOfSize:24.0];
    _itemColor = [UIColor blackColor];
    showGlass = NO;
//    peekInset = UIEdgeInsetsMake(0, 0, 0, 0);
    currentIndex = 0;
    itemCount = 0;
}

- (void)drawRect:(CGRect)rect {
    
    // Draw background
    [self.backgroundImage drawInRect:self.bounds];
    
    // Draw super/UIScrollView
    [super drawRect:rect];
    
    // Draw shadow
    [self.shadowImage drawInRect:self.bounds];
    
    // Draw glass
    if (self.showGlass) {
        [self.glassImage drawInRect:CGRectInset(self.bounds, 20, 0.0)];
    }
}

- (void)setShowGlass:(BOOL)doShowGlass {
    if (showGlass != doShowGlass) {
        showGlass = doShowGlass;
        [self setNeedsDisplay];
    }
}

//- (void)setPeekInset:(UIEdgeInsets)aPeekInset {
//    if (!UIEdgeInsetsEqualToEdgeInsets(peekInset, aPeekInset)) {
//        peekInset = aPeekInset;
//        //self.contentView.frame = UIEdgeInsetsInsetRect(self.bounds, self.peekInset);
//        [self reloadData];
//        //[self.contentView setNeedsDisplay];
//    }
//}


#pragma mark - Buisiness

- (void)reloadData
{
    // empty views
    currentIndex = 0;
    itemCount = 0;
    
    if ([pickerDataSource respondsToSelector:@selector(numberOfItemsInPickerView:)]) {
        itemCount = [pickerDataSource numberOfItemsInPickerView:self];
    } else {
        itemCount = 0;
    }
    
    self.items = [NSMutableArray arrayWithCapacity:itemCount];
    for (int i=0; i<itemCount; i++)
    {
        [self.items addObject:[NSNull null]];
    }
    
    [self scrollToIndex:0 animated:NO];
    self.contentSize = CGSizeMake(self.frame.size.width * itemCount, self.frame.size.height);
    self.content.frame = CGRectMake(0.0, 0.0, self.bounds.size.width * itemCount, self.bounds.size.height);
    [self tileViews];
}




- (void)determineCurrentItem
{
    CGFloat delta = self.contentOffset.x;
    int position = floorf(delta / self.frame.size.width);
    currentIndex = position;
    if ([pickerDelegate respondsToSelector:@selector(pickerView:didSelectItem:)]) {
        [pickerDelegate pickerView:self didSelectItem:currentIndex];
    }
}

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self scrollToIndex:index animated:animated];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    [self setContentOffset:CGPointMake(self.frame.size.width * index, 0.0) animated:animated];
}




#pragma mark - recycle queue

- (BOOL)isDisplayingViewForIndex:(NSUInteger)index
{
	if ([self.items objectAtIndex:index] != [NSNull null]) {
        return YES;
    }
    
    return NO;
}


- (void)tileViews
{
    // Calculate which pages are visible
    int currentViewIndex = floorf(self.contentOffset.x / self.frame.size.width);
    int firstNeededViewIndex = currentViewIndex - 2; 
    int lastNeededViewIndex  = currentViewIndex + 2;
    firstNeededViewIndex = MAX(firstNeededViewIndex, 0);
    lastNeededViewIndex  = MIN(lastNeededViewIndex, self.itemCount - 1);
    
    for (int i=0; i<=(self.items.count - 1); i++) {
        if (i >= firstNeededViewIndex && i <= lastNeededViewIndex) {
            [self configureItemAtIndex:i];
            [self.content setNeedsDisplay];
        } else {
            [self.items replaceObjectAtIndex:i withObject:[NSNull null]];
        }
    }
}

- (void)configureItemAtIndex:(NSUInteger)index {
    NSString *text;
    if ([pickerDataSource respondsToSelector:@selector(pickerView:titleForItem:)]) {
        text = [pickerDataSource pickerView:self titleForItem:index];
    }
    
    [self.items replaceObjectAtIndex:index withObject:text];
}
        



@end

