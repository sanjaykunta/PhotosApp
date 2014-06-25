//
//  ViewController.m
//  PhotosApp
//
//  Created by Sanjay Kumar Kunta on 6/23/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import "ImageListViewController.h"
#import "PXImage.h"
#import "PXUser.h"
#import "PXImageFetcher.h"
#import "ImageTableViewCell.h"
#import "ImageDownloader.h"
#import "AppDelegate.h"
#import "FullScreenImageViewController.h"

#define FullScreeImageSegueIdentifier @"FullImageSegueIdentifier"

@interface ImageListViewController () <UITableViewDataSource, UITableViewDelegate, FullScreenImageViewControllerDelegate, UIAlertViewDelegate>{
    UIImageView* transitionImageView;
}
@property (nonatomic, weak) IBOutlet UITableView* imagesTableView;
@property (nonatomic, weak) IBOutlet UIView* progressView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) ImageDownloader* imgDownloader;
@property (nonatomic, copy) NSArray* images;

- (IBAction)didTapSearch:(id)sender;
@end

@implementation ImageListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imgDownloader = [[ImageDownloader alloc] init];
    [self fetchPopularImages];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:FullScreeImageSegueIdentifier]) {
        PXImage* imgData = _images[_imagesTableView.indexPathForSelectedRow.row];
        FullScreenImageViewController* fullScreenVC = segue.destinationViewController;
        fullScreenVC.delegate = self;
        fullScreenVC.image = [_imgDownloader cachedImageForURLString:imgData.urls[0]];
    }
}

#pragma mark - Helper methods
- (IBAction)didTapSearch:(id)sender{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter a search term" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Search", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)search500PXWithSearchTerm:(NSString*)searchTerm{
    _progressView.hidden = NO;
    _progressView.alpha = 0.0f;
    [_activityIndicator startAnimating];
    __weak ImageListViewController* weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.progressView.alpha = 1.0f;
    }];
    [PXImageFetcher fetchImagesForSearchTerm: searchTerm completion:^(NSArray *images, NSError *error) {
        [weakSelf updateTableViewWithImages:images error:error];
    }];
}

- (void)fetchPopularImages{
    _progressView.hidden = NO;
    _progressView.alpha = 0.0f;
    [_activityIndicator startAnimating];
    __weak ImageListViewController* weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.progressView.alpha = 1.0f;
    }];
    [PXImageFetcher fetchPopularPhotosWithCompletion:^(NSArray *images, NSError *error) {
        [weakSelf updateTableViewWithImages:images error:error];
    }];
}

- (void)updateTableViewWithImages:(NSArray *)images error:(NSError *)error {
    __weak ImageListViewController* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.progressView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            weakSelf.progressView.hidden = YES;
            [weakSelf.activityIndicator stopAnimating];
        }];
    });
    
    if (!error) {
        self.images = images;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imagesTableView reloadData];
        });
    }else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"There seems to be issues with your network. Please check your network connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString* searchTerm = [alertView textFieldAtIndex:0].text;
    if (searchTerm.length) {
        [self search500PXWithSearchTerm:searchTerm];
    }
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _images.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"ImageCell";
    ImageTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    PXImage* imgData = _images[indexPath.row];
    cell.imageNameLabel.text = imgData.name;
    cell.userNameLabel.text = imgData.user.fullName;
    cell.ratingLabel.text = [NSString stringWithFormat:@"%@", imgData.rating];
    
    cell.thumbnailImageView.image = nil;
    //If the image has already failed downloading do not donwload it again.
    if (!imgData.failed && imgData.urls.count > 0) {
        NSString* imgURLString = imgData.urls[0];
        [_imgDownloader imageForURLString:imgURLString completion:^(UIImage *image, NSString *urlString) {
            if (!image) {
                imgData.failed = YES;
            }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                ImageTableViewCell* tableCell = (ImageTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
                if (tableCell) {
                    [tableCell.thumbnailImageView setImage:image];
                    [tableCell layoutSubviews];
                }
            });
            }
        }];
    }
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PXImage* imgData = _images[indexPath.row];
    if (imgData.urls.count > 0) {
        NSString* imgURLString = imgData.urls[0];
        UIImage* img = [_imgDownloader cachedImageForURLString:imgURLString];
        if (img) {
            ImageTableViewCell* tableCell = (ImageTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            CGPoint point = [tableCell convertPoint:tableCell.thumbnailImageView.frame.origin toView:self.view];
            
            //Position image correctly right above the cells image view
            transitionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(point.x, point.y, tableCell.thumbnailImageView.frame.size.width, tableCell.thumbnailImageView.frame.size.height)];
            transitionImageView.contentMode = UIViewContentModeScaleAspectFit;
            transitionImageView.backgroundColor = [UIColor blackColor];
            //add it to UIWindow as we want the image to animate over navigation bar
            [((AppDelegate*)[[UIApplication sharedApplication] delegate]).window addSubview:transitionImageView];
            transitionImageView.image = img;
            
            //disable user interaction until the animation is completed.
            self.view.userInteractionEnabled = NO;
            __weak ImageListViewController* weakSelf = self;
            //animate image to full screen
            [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseIn animations:^{
                transitionImageView.frame = CGRectMake(0, 0, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
            } completion:^(BOOL finished) {
                [transitionImageView removeFromSuperview];
                weakSelf.view.userInteractionEnabled = YES;
                [weakSelf performSegueWithIdentifier:FullScreeImageSegueIdentifier sender:self];
            }];
        }
    }
}

#pragma mark - FullScreenDelegate methods
- (void)fullScreenImageViewControllerClosed{
    //add image to view instead of application window so that the top image if its under navigation bar animates properly
    [self.view addSubview:transitionImageView];
    [self dismissViewControllerAnimated:NO completion:^{
        ImageTableViewCell* tableCell = (ImageTableViewCell*)[self.imagesTableView cellForRowAtIndexPath:self.imagesTableView.indexPathForSelectedRow];
        CGPoint point = [tableCell convertPoint:tableCell.thumbnailImageView.frame.origin toView:self.view];
        CGRect finalFrame = CGRectMake(point.x, point.y, tableCell.thumbnailImageView.frame.size.width, tableCell.thumbnailImageView.frame.size.height);
        
        self.view.userInteractionEnabled = NO;
        __weak ImageListViewController* weakSelf = self;
        //animate image back to its normal position
        [UIView animateWithDuration:0.75 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseIn animations:^{
            transitionImageView.frame = finalFrame;
        } completion:^(BOOL finished) {
            weakSelf.view.userInteractionEnabled = YES;
            [transitionImageView removeFromSuperview];
            transitionImageView = nil;
        }];
    }];
}

@end
