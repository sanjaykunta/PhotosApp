//
//  ImageDownloader.h
//  PhotosApp
//
//  Created by Sanjay Kunta on 6/24/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ImageDownloaderCompletion)(UIImage* image, NSString* urlString);

//This class helps dwonload images from the network. Once the image is downloaded it is saved in cache. From the next call onward cached image is returned.
@interface ImageDownloader : NSObject

// Once image is downloaded the completion block gets called. This method first checks cache and if there is no image in cache then it downloads the image from the server.
- (void)imageForURLString:(NSString*)urlString completion:(ImageDownloaderCompletion)completion;
// Returns image from cache. nil is returned if image is not cached.
- (UIImage*)cachedImageForURLString:(NSString*)urlString;

@end
