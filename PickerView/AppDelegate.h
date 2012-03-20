//
//  AppDelegate.h
//  PickerView
//
//  Created by Fraerman Arkady on 24.11.11.
//  Modified by Charles Powell on 3/19/12.
//

#import <UIKit/UIKit.h>

@class TableViewController;
@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *viewController;
@property (strong, nonatomic) TableViewController *tableViewController;
@property (strong, nonatomic) ViewController *normalViewController;

@end
