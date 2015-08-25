//
//  AppDelegate.m
//  Malayalam Christian Songs
//
//  Created by Jacob, Jeesmon on 4/16/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "Song.h"
#import "SongDao.h"
#import "UIDeviceHardware.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    SongDao *songDao = [[SongDao alloc] init];
    bool copyStatus = [songDao copyBookmarksDatabase];
    if(!copyStatus) {
        NSLog(@"Error copying bookmarks database");
    }
    
    BOOL isOS7 = NO;
    if ([UIDeviceHardware isOS7Device]) {
        isOS7 = YES;
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        MasterViewController *masterViewController = [[MasterViewController alloc] init];
        DetailViewController *detailViewController = [[DetailViewController alloc] init];
        
        masterViewController.detailViewController = detailViewController;
                                                      
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        
        if (isOS7) self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        
        self.window.rootViewController = self.navigationController;
    } else {
        MasterViewController *masterViewController = [[MasterViewController alloc] init];
        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        if (isOS7) masterNavigationController.navigationBar.tintColor = [UIColor blackColor];
        
        DetailViewController *detailViewController = [[DetailViewController alloc] init];
        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        if (isOS7) detailNavigationController.navigationBar.tintColor = [UIColor blackColor];
    	
        Song *song = [songDao fetchFirstSong:@"songs" withLangType:SongLangTypeMalayalam];
        
    	masterViewController.detailViewController = detailViewController;
        [masterViewController.detailViewController setSelectedSong:song];
    	
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = detailViewController;
        self.splitViewController.viewControllers = @[masterNavigationController, detailNavigationController];
        
        self.window.rootViewController = self.splitViewController;
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
