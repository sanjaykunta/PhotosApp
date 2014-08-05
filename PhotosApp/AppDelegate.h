//
//  AppDelegate.h
//  PhotosApp
//
//  Created by Sanjay Kumar Kunta on 6/23/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreData;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSManagedObjectContext* context;
@property (strong, nonatomic) NSManagedObjectModel* model;
@property (strong, nonatomic) NSPersistentStoreCoordinator* persistent;

@end
