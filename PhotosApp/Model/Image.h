//
//  Image.h
//  PhotosApp
//
//  Created by sanjay on 8/3/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Image : NSManagedObject

@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSManagedObject *user;

@end
