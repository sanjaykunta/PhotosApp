//
//  ImageTableViewCell.h
//  PhotosApp
//
//  Created by Sanjay Kumar Kunta on 6/24/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView* thumbnailImageView;
@property (nonatomic, weak) IBOutlet UILabel* imageNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* ratingLabel;


@end
