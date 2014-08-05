//
//  ViewController.m
//  PhotosApp
//
//  Created by Sanjay Kumar Kunta on 6/23/14.
//  Copyright (c) 2014 Kent State University. All rights reserved.
//

#import "ImageListViewController.h"
#import "PXImageFetcher.h"
#import "ImageTableViewCell.h"
#import "ImageDownloader.h"
#import "AppDelegate.h"
#import "FullScreenImageViewController.h"
#import "Image.h"

#define FullScreeImageSegueIdentifier @"FullImageSegueIdentifier"

@interface ImageListViewController () <UITableViewDataSource, UITableViewDelegate, FullScreenImageViewControllerDelegate, UIAlertViewDelegate>{
    UIImageView* transitionImageView;
}
@property (nonatomic, weak) IBOutlet UITableView* imagesTableView;
@property (nonatomic, weak) IBOutlet UIView* activityIndicatorHolderView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) ImageDownloader* imgDownloader;
@property (nonatomic,strong) NSFetchedResultsController* fecthedResultsController;

- (IBAction)didTapSearch:(id)sender;
@end

@implementation ImageListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _activityIndicatorHolderView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    _imgDownloader = [[ImageDownloader alloc] init];
    [self fetchPopularImages];
}

-(NSFetchedResultsController*) fecthedResultsController{
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];

    
    if (_fecthedResultsController != nil) {
        return _fecthedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:appDelegate.context];
[fetchRequest setEntity:entity];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"imageName" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    _fecthedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:appDelegate.context sectionNameKeyPath:nil cacheName:nil];
    NSError* error;
    if (![_fecthedResultsController performFetch:&error]) {
        NSLog(@"%@",error);
    }
    
    
    return _fecthedResultsController;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:FullScreeImageSegueIdentifier]) {
        NSIndexPath *indexPath = [self.imagesTableView indexPathForSelectedRow];
        Image* imgData = [self.fecthedResultsController objectAtIndexPath:indexPath];
        FullScreenImageViewController* fullScreenVC = segue.destinationViewController;
        fullScreenVC.delegate = self;
//        fullScreenVC.image = [_imgDownloader cachedImageForURLString:imgData.urls[0]];
        [_imgDownloader imageForURLString:imgData.imageUrl completion:^(UIImage *image, NSString *urlString) {
            fullScreenVC.image = image;
        }];
    }
}

#pragma mark - Helper methods
- (IBAction)didTapSearch:(id)sender{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter a search term" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Search", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)search500PXWithSearchTerm:(NSString*)searchTerm{
    _activityIndicatorHolderView.hidden = NO;
    _activityIndicatorHolderView.alpha = 0.0f;
    [_activityIndicator startAnimating];
    __weak ImageListViewController* weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.activityIndicatorHolderView.alpha = 1.0f;
    }];
    [PXImageFetcher fetchImagesForSearchTerm: searchTerm completion:^(NSError *error) {
        [weakSelf updateTableViewWithError:error];
    }];
}

- (void)fetchPopularImages{
    _activityIndicatorHolderView.hidden = NO;
    _activityIndicatorHolderView.alpha = 0.0f;
    [_activityIndicator startAnimating];
    __weak ImageListViewController* weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.activityIndicatorHolderView.alpha = 1.0f;
    }];
    [PXImageFetcher fetchPopularPhotosWithCompletion:^(NSError *error) {
       [weakSelf updateTableViewWithError:error];
    }];
}

- (void)updateTableViewWithError:(NSError *)error {
    __weak ImageListViewController* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.activityIndicatorHolderView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            weakSelf.activityIndicatorHolderView.hidden = YES;
            [weakSelf.activityIndicator stopAnimating];
        }];
    });
    
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.fecthedResultsController performFetch:nil];
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
    id <NSFetchedResultsSectionInfo> secInfo = [[self.fecthedResultsController sections]objectAtIndex:section];
    return [secInfo numberOfObjects];
    }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"ImageCell";
    ImageTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Image *imgObj = [self.fecthedResultsController objectAtIndexPath:indexPath];
    cell.imageNameLabel.text = imgObj.imageName;
    cell.ratingLabel.text = [NSString stringWithFormat:@"%@",imgObj.rating];
    if (imgObj.imageUrl) {
        [_imgDownloader imageForURLString:imgObj.imageUrl completion:^(UIImage *image, NSString *urlString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ImageTableViewCell* cell = (ImageTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
                if (cell) {
                    [cell.thumbnailImageView setImage:image];
                }
            });
        }];
    }
    
   
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Image* imgData = [self.fecthedResultsController objectAtIndexPath:indexPath];
    if (imgData.imageUrl) {
        NSString* imgURLString = imgData.imageUrl;
//        UIImage* img = [_imgDownloader cachedImageForURLString:imgURLString];
        [_imgDownloader imageForURLString:imgURLString completion:^(UIImage *image, NSString *urlString) {
            UIImage *img = image;
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
        }];
       

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
