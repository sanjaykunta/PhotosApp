//
//  AppDelegate.m
//  PhotosApp
//
//  Created by Sanjay Kumar Kunta on 6/23/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import "AppDelegate.h"
#import <PXAPI/PXAPI.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [PXRequest setConsumerKey:@"MFR0Z1dZKgvq7fS1s56BGDqNBSN89MAZDEz4hlI2" consumerSecret:@"pgZEWkd4hixV077MjmEus1oMOByy0SqkqkoOZ1zt"];
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

-(NSManagedObjectContext*) context{
    
    if (_context != nil) {
        return _context;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistent];
    if (coordinator != nil) {
        _context = [[NSManagedObjectContext alloc]init];
        [_context setPersistentStoreCoordinator:coordinator];
    }
    return _context;
}

-(NSManagedObjectModel*) model{
    
    if (_model != nil) {
        return _model;
    }
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"PhotosApp" withExtension:@"momd"];
    _model = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelUrl];
    return _model;
}

-(NSPersistentStoreCoordinator*) persistent{
    
    if (_persistent != nil) {
        return _persistent;
    }
    NSURL* storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PhotosApp.sqlite"];
    NSError* error = nil;
    _persistent = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self model]];
    if(![_persistent addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]){
        NSLog(@"Unresolved error %@,%@",error,[error userInfo]);
        abort();
    }
    return _persistent;
}

-(NSURL*) applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
}

@end
