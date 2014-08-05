//
//  User.h
//  PhotosApp
//
//  Created by sanjay on 8/3/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSSet *images;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
