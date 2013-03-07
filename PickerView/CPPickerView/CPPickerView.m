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

@interface CPPickerView ()
// Views
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *glassImage;
@property (nonatomic, strong) UIImage *shadowImage;

@end

@implementation CPPickerView

@synthesize dataSource;
@synthesize delegate;
@synthesize contentView;
@synthesize glassImage, backgroundImage, shadowImage;
@synthesize selectedItem = currentIndex;
@synthesize itemFont = _itemFont;
@synthesize itemColor = _itemColor;
@synthesize showGlass, peekInset;

#pragma mark - Custom getters/setters

- (void)setSelectedItem:(int)selectedItem
{
    if (selectedItem >= itemCount)
        return;
    
    currentIndex = selectedItem;
    [self scrollToIndex:currentIndex animated:NO];
}




- (void)setItemFont:(UIFont *)itemFont
{
    _itemFont = itemFont;
    
    for (UILabel *aLabel in visibleViews) 
    {
        aLabel.font = _itemFont;
    }
    
    for (UILabel *aLabel in recycledViews) 
    {
        aLabel.font = _itemFont;
    }
}

- (void)setItemColor:(UIColor *)itemColor
{
    _itemColor = itemColor;
    
    for (UILabel *aLabel in visibleViews) 
    {
        aLabel.textColor = _itemColor;
    }
    
    for (UILabel *aLabel in recycledViews) 
    {
        aLabel.textColor = _itemColor;
    }
}

#pragma mark - Initialization


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self commonInit];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    // setup
    [self setup];

    // content
    self.contentView = [[UIScrollView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, self.peekInset)];
    self.contentView.clipsToBounds = NO;
    self.contentView.showsHorizontalScrollIndicator = NO;
    self.contentView.showsVerticalScrollIndicator = NO;
    self.contentView.pagingEnabled = YES;
    self.contentView.scrollsToTop = NO;
    self.contentView.delegate = self;
    [self addSubview:self.contentView];

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
    self.clipsToBounds = YES;
    self.layer.borderColor = [UIColor colorWithWhite:0.15 alpha:1.0].CGColor;
    self.layer.borderWidth = 0.5f;
}


- (void)setup
{
    _itemFont = [UIFont boldSystemFontOfSize:24.0];
    _itemColor = [UIColor blackColor];
    showGlass = NO;
    peekInset = UIEdgeInsetsMake(0, 0, 0, 0);
    currentIndex = 0;
    itemCount = 0;
    visibleViews = [[NSMutableSet alloc] init];
    recycledViews = [[NSMutableSet alloc] init];
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
        [self.glassImage drawInRect:CGRectMake(self.frame.size.width / 2 - 30, 0.0, 60, self.frame.size.height)];
    }
}

- (void)setShowGlass:(BOOL)doShowGlass {
    if (showGlass != doShowGlass) {
        showGlass = doShowGlass;
        [self setNeedsDisplay];
    }
}

- (void)setPeekInset:(UIEdgeInsets)aPeekInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(peekInset, aPeekInset)) {
        peekInset = aPeekInset;
        self.contentView.frame = UIEdgeInsetsInsetRect(self.bounds, self.peekInset);
        [self reloadData];
        [self.contentView setNeedsDisplay];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if ([self pointInside:point withEvent:event]) {
        return self.contentView;
    }
    
    return nil;
}


#pragma mark - Data handling and interaction

- (void)reloadData
{
    // empty views
    currentIndex = 0;
    itemCount = 0;
    
    for (UIView *aView in visibleViews) 
        [aView removeFromSuperview];
    
    for (UIView *aView in recycledViews)
        [aView removeFromSuperview];
    
    visibleViews = [[NSMutableSet alloc] init];
    recycledViews = [[NSMutableSet alloc] init];
    
    if ([dataSource respondsToSelector:@selector(numberOfItemsInPickerView:)]) {
        itemCount = [dataSource numberOfItemsInPickerView:self];
    } else {
        itemCount = 0;
    }
    
    [self scrollToIndex:0 animated:NO];
    self.contentView.frame = UIEdgeInsetsInsetRect(self.bounds, self.peekInset);
    self.contentView.contentSize = CGSizeMake(self.contentView.frame.size.width * itemCount, self.contentView.frame.size.height);  
    [self tileViews];
}




- (void)determineCurrentItem
{
    CGFloat delta = self.contentView.contentOffset.x;
    int position = round(delta / self.contentView.frame.size.width);
    currentIndex = position;
    if ([delegate respondsToSelector:@selector(pickerView:didSelectItem:)]) {
        [delegate pickerView:self didSelectItem:currentIndex];
    }
}

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self scrollToIndex:index animated:animated];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    [self.contentView setContentOffset:CGPointMake(self.contentView.frame.size.width * index, 0.0) animated:animated];
}




#pragma mark - recycle queue

- (UIView *)dequeueRecycledView
{
	UIView *aView = [recycledViews anyObject];
	
    if (aView) 
        [recycledViews removeObject:aView];
    return aView;
}



- (BOOL)isDisplayingViewForIndex:(NSUInteger)index
{
	BOOL foundPage = NO;
    for (UIView *aView in visibleViews) 
	{
        int viewIndex = aView.frame.origin.x / self.contentView.frame.size.width;
        if (viewIndex == index) 
		{
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}




- (void)tileViews
{
    // Calculate which pages are visible
    CGRect visibleBounds = self.contentView.bounds;
    int currentViewIndex = floorf(self.contentView.contentOffset.x / self.contentView.frame.size.width);
    int firstNeededViewIndex = currentViewIndex - 2; 
    int lastNeededViewIndex  = currentViewIndex + 2;
    firstNeededViewIndex = MAX(firstNeededViewIndex, 0);
    lastNeededViewIndex  = MIN(lastNeededViewIndex, itemCount - 1);
	
    // Recycle no-longer-visible pages 
	for (UIView *aView in visibleViews) 
    {
        int viewIndex = aView.frame.origin.x / visibleBounds.size.width - 2;
        if (viewIndex < firstNeededViewIndex || viewIndex > lastNeededViewIndex) 
        {
            [recycledViews addObject:aView];
            [aView removeFromSuperview];
        }
    }
    
    [visibleViews minusSet:recycledViews];
    
    // add missing pages
	for (int index = firstNeededViewIndex; index <= lastNeededViewIndex; index++) 
	{
        if (![self isDisplayingViewForIndex:index]) 
		{
            UILabel *label = (UILabel *)[self dequeueRecycledView];
            
			if (label == nil)
            {
				label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
                label.backgroundColor = [UIColor clearColor];
                label.font = self.itemFont;
                label.textColor = self.itemColor;
                label.textAlignment = NSTextAlignmentCenter;
            }
            
            [self configureView:label atIndex:index];
            [self.contentView addSubview:label];
            [visibleViews addObject:label];
        }
    }
}




- (void)configureView:(UIView *)view atIndex:(NSUInteger)index
{
    UILabel *label = (UILabel *)view;
    
    if ([dataSource respondsToSelector:@selector(pickerView:titleForItem:)]) {
        label.text = [dataSource pickerView:self titleForItem:index];
    }
    
    CGRect frame = label.frame;
    frame.origin.x = self.contentView.frame.size.width * index;
    label.frame = frame;
}




#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self tileViews];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self determineCurrentItem];
}


@end
