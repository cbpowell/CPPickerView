## Description

A custom, configurable, horizontal version of UIPickerView.

Also included is CPPickerViewCell, a UITableViewCell sublcass that adds a CPPickerView to the right side of the cell. This cell was envisioned for a settings-type view, allowing a multi-option setting to be handled in a single table row (whereas normally it would require a disclosure or multiple rows).

If you're interested in a vertical custom UIPickerView controller, check out [AFPickerView](https://github.com/arkichek/AFPickerView) by Arkady Fraerman! This code is essentially forked from his project.

![CPPickerView screenshot](http://cbpowell.github.com/CPPickerView/screenshot.png)

CPPickerView is currently in use by at least one approved app in the App Store (Hipmunk for iPhone/iPad!).

## Usage

### General

To customize the appearance, replace the following images with your own:

 * wheelBackground.png
 * stretchableGlass.png
 * shadowOverlay.png

__NOTE__: CPPickerView uses `- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets` (for iOS 5.0 and up) or `- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets` (for below iOS 5.0) to stretch _wheelBackground.png_ and _stretchableGlass.png_. Be sure to look at the sample images in relation to the cap sizes set in CPPickerView.m's `initWithFrame:` before changing the sizing of the images, as you may need to adjust the caps. _shadowOverlay.png_ is currently simply stretched to fit the frame.

Several appearance options are settable via properties:

 * `BOOL showGlass` - defines whether or not to show the "glass" overlay over the selected item.
 * `UIEdgeInsets peekInset` - defines the amount the item to the left and right of the currently selected item "peek" into view. This can be used as an indication to the user that there are other items, if desired. _NOTE_: You most likely want to leave the `top` and `bottom` inset values at 0, and adjust the `left` and `right` values. Larger inset values mean more peek.


### Standard Usage
Create a CPPickerView instance and configure it:

```objective-c
pickerView = [[CPPickerView alloc] initWithFrame:CGRectMake(30.0, 250.0, 126.0, 197.0)];
pickerView.rowFont = [UIFont boldSystemFontOfSize:19.0];
pickerView.rowIndent = 10.0;
pickerView.showGlass = YES;
```

Set the dataSource, delegate, and call `[pickerView reloadData]`:

```objective-c
pickerView.dataSource = self;
pickerView.delegate = self;
[pickerView reloadData];
```

Then implement CPPickerViewDataSource and CPPickerViewDelegate in your controller.

### CPPickerViewCell Usage

Use CPPickerViewCell like a normal UITableViewCell. Inside `tableView:cellForRowAtIndexPath:`, dequeue or create the cell:

```objective-c
CPPickerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
if (cell == nil) {
    cell = [[CPPickerViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
}
```

Set the data source and the delegate for the cell, and inform it of it's index path:

```objective-c
cell.dataSource = self;
cell.delegate = self;
cell.currentIndexPath = indexPath;
```

__NOTE__: CPPickerViewCells MUST be informed of their index path in the table, or you won't be able to distinguish between them in your datasource and delegate methods!

And implement CPPickerViewCellDataSource and CPPickerViewCellDelegate per the protocols. In the included example the TableViewController (i.e. `self`) is set up as the data source and delegate for all cells.

The data source/delegate methods for `CPPickerViewCell` convert the normal `CPPickerView` data source/delegate methods to refer to the requests for data by NSIndexPath rather than the CPPickerView object (to match the typical way table cells are identified).

Finally, reload the cell (aka the CPPickerView, the items in the picker will be requested again) and then reconfigure it with any specific settings for the given row if you're recalling some previously stored settings. Then return the cell.

```objective-c
[cell reloadData];
// Reconfigure
cell.showGlass = YES;
cell.peekInset = UIEdgeInsetsMake(0, 18, 0, 18);
NSInteger *storedSelectedIndex = [[AnArrayOfStoredStuff objectAtIndex:indexPath.row] intValue];
[cell selectItemAtIndex:storedSelectedIndex animated:NO];  //Unanimated, because this should be immediate
return cell;
```

## Todo
- Any ideas?

## About

Charles Powell
- [GitHub](http://github.com/cbpowell)
- [Twitter](http://twitter.com/seventhcolumn)

Give me a shout if you're using this in your project!
