//
//  PXImageFetcher.m
//  PhotosApp
//
//  Created by Sanjay Kunta on 6/24/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import "PXImageFetcher.h"
#import <PXAPI/PXAPI.h>
#import "PXImage.h"
#import "PXUser.h"

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
        //parse results in background queue
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray* photos = results[@"photos"];
            NSMutableArray* images = [NSMutableArray arrayWithCapacity:photos.count];
            for (NSDictionary* photo in photos) {
                PXImage* image = [[PXImage alloc] init];
                image.imageId = photo[@"id"];
                image.name = photo[@"name"];
                image.rating = photo[@"rating"];
                image.votesCount = photo[@"votes_count"];
                
                NSMutableArray* urls = [NSMutableArray array];
                for (NSArray* url in photo[@"image_url"]) {
                    [urls addObject:url];
                }
                image.urls = urls;
                
                PXUser* user = [[PXUser alloc] init];
                NSDictionary* userData = photo[@"user"];
                user.fullName = userData[@"fullname"];
                user.userId = userData[@"id"];
                image.user = user;
                
                [images addObject:image];
            }
            //call the completion block on main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(images, error);
            });
        });
        
    }else{
        //call the completion block on main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }
}

@end
