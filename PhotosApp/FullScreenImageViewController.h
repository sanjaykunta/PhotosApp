//
//  FullScreenImageViewController.h
//  PhotosApp
//
//  Created by Sanjay Kunta on 6/24/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FullScreenImageViewControllerDelegate <NSObject>

- (void)fullScreenImageViewControllerClosed;

@end

@interface FullScreenImageViewController : UIViewController
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, weak) id<FullScreenImageViewControllerDelegate> delegate;
@end
