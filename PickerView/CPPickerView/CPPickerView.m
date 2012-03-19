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


@interface CPPickerGlassView : UIView

@property (nonatomic, unsafe_unretained) UIImageView *leftBorder;
@property (nonatomic, unsafe_unretained) UIImageView *rightBorder;
@property (nonatomic, unsafe_unretained) UIImageView *center;

@end

@implementation CPPickerGlassView

@synthesize leftBorder, rightBorder, center;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = NO;
        
        UIImageView *newLeftBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glassLeft"]];
        newLeftBorder.frame = CGRectMake(0.0, 0.0, 1, self.frame.size.height);
        [self addSubview:newLeftBorder];
        self.leftBorder = newLeftBorder;
        
        UIImageView *newRightBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glassRight"]];
        newRightBorder.frame = CGRectMake(self.frame.size.width - 1, 0.0, 1, self.frame.size.height);
        [self addSubview:newRightBorder];
        self.rightBorder = newRightBorder;
        
        UIImageView *newCenter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glassCenter"]];
        newCenter.frame = CGRectMake(1.0, 0.0, self.frame.size.width - 2, self.frame.size.height);
        [self addSubview:newCenter];
        self.center = newCenter;
    }
    
    return self;
}

- (void)layoutSubviews {
    self.leftBorder.frame = CGRectMake(0.0, 0.0, 1, self.frame.size.height);
    self.rightBorder.frame = CGRectMake(self.frame.size.width - 1, 0.0, 1, self.frame.size.height);
    self.center.frame = CGRectMake(1.0, 0.0, self.frame.size.width - 2, self.frame.size.height);
}
@end

#import "CPPickerView.h"

@implementation CPPickerView

#pragma mark - Synthesization

@synthesize dataSource;
@synthesize delegate;
@synthesize selectedItem = currentIndex;
@synthesize itemFont = _itemFont;
@synthesize showGlass;




#pragma mark - Custom getters/setters

- (void)setSelectedItem:(int)selectedItem
{
    if (selectedItem >= itemCount)
        return;
    
    currentIndex = selectedItem;
    [self scrollToIndex:currentIndex animated:NO];
}




- (void)setRowFont:(UIFont *)rowFont
{
    _itemFont = rowFont;
    
    for (UILabel *aLabel in visibleViews) 
    {
        aLabel.font = _itemFont;
    }
    
    for (UILabel *aLabel in recycledViews) 
    {
        aLabel.font = _itemFont;
    }
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // setup
        [self setup];
        
        // content
        contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        contentView.showsHorizontalScrollIndicator = NO;
        contentView.showsVerticalScrollIndicator = NO;
        contentView.pagingEnabled = YES;
        contentView.delegate = self;
        [self addSubview:contentView];
        
        // shadows
        UIImageView *shadows = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadowOverlay"]];
        shadows.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        [self addSubview:shadows];
        
        // Rounded borders
        self.layer.cornerRadius = 3.0f;
        self.clipsToBounds = YES;
        self.layer.borderColor = [UIColor colorWithWhite:0.15 alpha:1.0].CGColor;
        self.layer.borderWidth = 0.5f;
    }
    return self;
}




- (void)setup
{
    _itemFont = [UIFont boldSystemFontOfSize:24.0];
    showGlass = NO;
    currentIndex = 0;
    itemCount = 0;
    visibleViews = [[NSMutableSet alloc] init];
    recycledViews = [[NSMutableSet alloc] init];
}

- (void)drawRect:(CGRect)rect {
    
    // Draw background
    UIImage *background = [UIImage imageNamed:@"wheelBackground"];
    [background drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    
    // Draw borders
    UIImage *borderTop = [UIImage imageNamed:@"wheelBorder"];
    UIImage *borderBottom = [UIImage imageWithCGImage:borderTop.CGImage
                                                scale:1.0 
                                          orientation:UIImageOrientationDownMirrored];
    [borderTop drawInRect:CGRectMake(0.0, 0.0, rect.size.width, borderTop.size.height)];
    [borderBottom drawInRect:CGRectMake(0.0, rect.size.height - borderTop.size.height, rect.size.width, borderTop.size.height)];
    
    
    [super drawRect:rect];
}

- (void)setShowGlass:(BOOL)doShowGlass {
    if (showGlass != doShowGlass) {
        if ([glassView superview] == nil) {
            glassView = (UIView *)[[CPPickerGlassView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 30, 0.0, 60, self.frame.size.height)];
            [self addSubview:glassView];
        } else {
            [glassView removeFromSuperview];
            glassView = nil;
        }
        
        showGlass = doShowGlass;
    }
}


#pragma mark - Buisiness

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
    contentView.contentSize = CGSizeMake(contentView.frame.size.width * itemCount, contentView.frame.size.height);  
    [self tileViews];
}




- (void)determineCurrentItem
{
    CGFloat delta = contentView.contentOffset.x;
    int position = round(delta / contentView.frame.size.width);
    currentIndex = position;
    //[contentView setContentOffset:CGPointMake(contentView.frame.size.width * position, 0.0) animated:YES];
    //[self scrollToIndex:position animated:YES];
    if ([delegate respondsToSelector:@selector(pickerView:didSelectItem:)]) {
        [delegate pickerView:self didSelectItem:currentIndex];
    }
}

- (void)selectItemAtItem:(NSInteger)index animated:(BOOL)animated {
    [self scrollToIndex:index animated:animated];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    [contentView setContentOffset:CGPointMake(contentView.frame.size.width * index, 0.0) animated:animated];
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
        int viewIndex = aView.frame.origin.x / contentView.frame.size.width;
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
    CGRect visibleBounds = contentView.bounds;
    int currentViewIndex = floorf(contentView.contentOffset.x / contentView.frame.size.width);
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
				label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, contentView.frame.size.width, contentView.frame.size.height)];
                label.backgroundColor = [UIColor clearColor];
                label.font = self.itemFont;
                label.textColor = RGBACOLOR(0.0, 0.0, 0.0, 0.75);
                label.textAlignment = UITextAlignmentCenter;
            }
            
            [self configureView:label atIndex:index];
            [contentView addSubview:label];
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
    frame.origin.x = contentView.frame.size.width * index;// + 78.0;
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
