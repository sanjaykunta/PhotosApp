//
//  FullScreenImageViewController.m
//  PhotosApp
//
//  Created by Sanjay Kunta on 6/24/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import "FullScreenImageViewController.h"

@interface FullScreenImageViewController ()
@property (nonatomic, weak) IBOutlet UIImageView* pxImageView;
- (IBAction)didTapImageView:(id)sender;
@end

@implementation FullScreenImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.pxImageView setImage:self.image];
}

- (IBAction)didTapImageView:(id)sender{
    if (self.delegate) {
        [self.delegate fullScreenImageViewControllerClosed];
    }
}

@end
