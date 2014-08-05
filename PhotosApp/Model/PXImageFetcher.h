//
//  PXImageFetcher.h
//  PhotosApp
//
//  Created by Sanjay Kunta on 6/24/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PXImageFetcherCompletion)(NSError*);

@interface PXImageFetcher : NSObject

//Searches 500Px with the search term. Once completed it calls completion block with an array of PXImage objects.
+ (void)fetchImagesForSearchTerm:(NSString*)searchTerm completion:(PXImageFetcherCompletion)completion;
//Gets popular photos from 500Px. Once completed it calls completion block with an array of PXImage objects.
+ (void)fetchPopularPhotosWithCompletion:(PXImageFetcherCompletion)completion;

@end
