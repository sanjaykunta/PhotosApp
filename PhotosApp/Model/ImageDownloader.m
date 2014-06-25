//
//  ImageDownloader.m
//  PhotosApp
//
//  Created by Sanjay Kunta on 6/24/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader()
@property (nonatomic, strong) NSMutableArray* downloadsInProgress;
@property (nonatomic, strong) NSOperationQueue* downloadQueue;
@property (nonatomic, strong) NSCache* cache;
@end

@implementation ImageDownloader

- (NSMutableArray *)downloadsInProgress {
    if (!_downloadsInProgress) {
        _downloadsInProgress = [[NSMutableArray alloc] init];
    }
    return _downloadsInProgress;
}

- (NSOperationQueue *)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.name = @"Download Queue";
        _downloadQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    }
    return _downloadQueue;
}

- (NSCache*)cache{
    if (!_cache) {
        _cache = [[NSCache alloc]init];
        [_cache setName:@"Download Cache"];
    }
    return _cache;
}

- (void)imageForURLString:(NSString*)urlString completion:(ImageDownloaderCompletion)completion{
    //First check if the image is in the cache. If not download it from the server.
    UIImage* cachedImg = [self cachedImageForURLString:urlString];
    if (cachedImg) {
        if (completion) {
            if (completion) {
                completion(cachedImg, urlString);
            }
        }
    }else{
        //Check if the image is already being downloaded. If not start downloading
        if (![self.downloadsInProgress containsObject:urlString]){
            [self.downloadsInProgress addObject:urlString];
            NSURL* imageURL = [NSURL URLWithString:urlString];
            __weak ImageDownloader* weakSelf = self;
            //Add operation to download images and save it to cache. Once completed call the completion block. 
            [self.downloadQueue addOperationWithBlock:^{
                //as the image has completed downloading remove the url from the downloadsInProgress array
                [weakSelf.downloadsInProgress removeObject:urlString];
                NSData* imageData = [NSData dataWithContentsOfURL:imageURL];
                if (imageData) {
                    UIImage* image = [UIImage imageWithData:imageData];
                    //save image to cache
                    [weakSelf.cache setObject:image forKey:urlString];
                    if (completion) {
                        completion(image, urlString);
                    }
                }else{
                    if (completion) {
                        completion(nil, urlString);
                    }
                }
            }];
        }
    }
}

- (UIImage*)cachedImageForURLString:(NSString*)urlString{
    //get image from cache
    return [self.cache objectForKey:urlString];
}

@end
