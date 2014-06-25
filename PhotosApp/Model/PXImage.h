//
//  PXImage.h
//  PhotosApp
//
//  Created by Sanjay Kumar Kunta on 6/24/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PXUser;

@interface PXImage : NSObject
@property (nonatomic, strong) NSNumber* imageId;
@property (nonatomic, copy) NSArray* urls;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, strong) NSNumber* rating;
@property (nonatomic, strong) NSNumber* votesCount;
@property (nonatomic, strong) PXUser* user;
@property (nonatomic, getter = isFailed) BOOL failed;
@end
