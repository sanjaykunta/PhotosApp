//
//  PXImageFetcher.m
//  PhotosApp
//
//  Created by Sanjay Kunta on 6/24/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import "PXImageFetcher.h"
#import <PXAPI/PXAPI.h>
#import "Image.h"
#import "User.h"
#import "AppDelegate.h"
@import CoreData;

@implementation PXImageFetcher

+ (void)fetchImagesForSearchTerm:(NSString*)searchTerm completion:(PXImageFetcherCompletion)completion{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    //Search images
    [PXRequest requestForSearchTerm:searchTerm page:0 resultsPerPage:50 completion:^(NSDictionary *results, NSError *error) {
        [self parseResults:error completion:completion results:results];
    }];
}

+ (void)fetchPopularPhotosWithCompletion:(PXImageFetcherCompletion)completion{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    //Get popular photos
    [PXRequest requestForPhotoFeature:PXAPIHelperPhotoFeaturePopular resultsPerPage:50 completion:^(NSDictionary *results, NSError *error) {
        [self parseResults:error completion:completion results:results];
    }];
}

+ (void)parseResults:(NSError *)error completion:(PXImageFetcherCompletion)completion results:(NSDictionary *)results {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (results) {
            NSArray* photos = results[@"photos"];
            for (NSDictionary* photo in photos) {
                
                AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                
                NSMutableArray* urls = [NSMutableArray array];
                for (NSArray* url in photo[@"image_url"]) {
                    [urls addObject:url];
                }
                NSString* imageURL = urls[0];
                
                NSFetchRequest *fetch = [[NSFetchRequest alloc]initWithEntityName:@"Image"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageUrl == %@", imageURL];
                [fetch setPredicate:predicate];
                NSError* fetchError;
                NSArray* objs = [appDelegate.context executeFetchRequest:fetch error:&fetchError];
                if (!objs.count) {
                    //Create Image object (nsmanagedobject)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        Image* img = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:appDelegate.context];
                        img.imageName = photo[@"name"];
                        img.rating = photo[@"rating"];
                        img.imageUrl = imageURL;
                        //Create User object
                        User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:appDelegate.context];
                        NSDictionary* userData = photo[@"user"];
                        
                        user.fullName = userData[@"fullName"];
                        user.userId = userData[@"id"];
                        
                        //Add add image to user object
                        [user addImagesObject:img];
                        
                        //save object
                        NSError *saveError;
                        if (![appDelegate.context save:&saveError]) {
                            NSLog(@"Error%@",saveError);
                        }
                    });
                }
                
                
               
                
                
            }
            //call the completion block on main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        
    }else{
        //call the completion block on main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }
}

@end
