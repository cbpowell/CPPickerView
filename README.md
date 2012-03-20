## Description

A custom, configurable, horizontal version of UIPickerView.

Also included is CPPickerViewCell, a UITableViewCell sublcass that adds a CPPickerView to the right side of the cell. This cell was envisioned for a settings-type view, allowing a multi-option setting to be handled in a single table row (whereas normally it would require a disclosure or multiple rows).

If you're interested in a vertical custom UIPickerView controller, check out [AFPickerView](https://github.com/arkichek/AFPickerView) by Arkady Fraerman! This code is essentially forked from his project.

![CPPickerView screenshot](http://cbpowell.github.com/CPPickerView/screenshot.png)
## Usage

### Normal

To customize the appearance, replace the following images with your own:

 * wheelBackground.png
 * wheelBorder.png
 * glassLeft.png, glassRight.png, glassCenter.png
 * shadowOverlay.png

Create AFPickerView instance and customize it

```objective-c
pickerView = [[AFPickerView alloc] initWithFrame:CGRectMake(30.0, 250.0, 126.0, 197.0)];
pickerView.rowFont = [UIFont boldSystemFontOfSize:19.0];
pickerView.rowIndent = 10.0;
pickerView.showGlass = YES;
```

Set the dataSource, delegate and call `[pickerView reloadData]`

```objective-c
pickerView.dataSource = self;
pickerView.delegate = self;
[pickerView reloadData];
```

Implement CPPickerViewDataSource and CPPickerViewDelegate

### CPPickerViewCell

Use CPPickerViewCell like a normal UITableViewCell. Inside `tableView:cellForRowAtIndexPath:`, dequeue or create the cell:

```objective-c
CPPickerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
if (cell == nil) {
    cell = [[CPPickerViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
}
```

Set the data source and the delegate for the cell:

```objective-c
cell.dataSource = self;
cell.delegate = self;
```

And implement CPPickerViewCellDataSource and CPPickerViewCellDelegate per the protocols. In the included example the TableViewController (i.e. `self`) is set up as the data source and delegate for all cells. The data source/delegate methods for `CPPickerViewCell` convert the normal `CPPickerView` data source/delegate methods to refer to the requests for data by NSIndexPath rather than the CPPickerView object (to match the typical way cells are tracked).

Finally, reload the cell (aka the CPPickerView, the items in the picker will be requested again) and then reconfigure it with any specific settings for the given row if you're recalling some previously stored settings. Then return the cell.

```objective-c
[cell reloadData];
// Reconfigure
cell.showGlass = YES;
NSInteger *storedSelectedIndex = [[AnArrayOfStoredStuff objectAtIndex:indexPath.row] intValue];
[cell selectItemAtIndex:storedSelectedIndex animated:NO];  //Unanimated, because this should be immediate
return cell;
```

## Todo
- Use UIImage's  `stretchableImageWithLeftCapWidth:` method instead of 3 UIImageViews for the glass
- Allow left/right item from center to "peek" into view, to indicate there are other options

## About

Charles Powell
- [GitHub](http://github.com/cbpowell)
- [Twitter](http://twitter.com/seventhcolumn)

Give me a shout if you're using this in your project!