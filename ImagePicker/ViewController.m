//
//  ViewController.m
//  ImagePicker
//
//  Created by steve on 2016-03-22.
//  Copyright © 2016 steve. All rights reserved.
//

#import "ViewController.h"

// for AVPlayer
@import AVFoundation;

//  for AVPlayerViewController
@import AVKit;

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

#pragma mark - Button Actions

- (IBAction)albumTapped:(UIBarButtonItem *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        return;
    }
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    ipc.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                      UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:ipc animated:YES completion:^{
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }];
}

- (IBAction)libraryTapped:(UIBarButtonItem *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return;
    }
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    ipc.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                      UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:ipc animated:YES completion:^{
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }];
}

- (IBAction)cameraTapped:(UIBarButtonItem *)sender {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    NSLog(@"%@", sourceTypes);
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    ipc.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
      UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark - Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"%@", info);
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    [self dismissViewControllerAnimated:YES completion:^ {
        if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) {
            NSLog(@"is movie");
            NSURL *url = info[UIImagePickerControllerMediaURL];
            // play video
            [self playVideoAtPath:url];
            // [self saveMovieWithInfo:info];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"Was cancelled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

// play video
- (void)playVideoAtPath:(NSURL *)path {
    AVPlayer *player = [AVPlayer playerWithURL:path];
    AVPlayerViewController *pvc = [AVPlayerViewController new];
    pvc.player = player;
    // [pvc.player play]; // if you want to start by playing
    [self presentViewController:pvc animated:YES completion:nil];
}

#pragma mark - Saving Video

// saves video to Photo Album
- (void)saveMovieWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSURL *url = info[UIImagePickerControllerMediaURL];
    
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path])) {
        // save it
        UISaveVideoAtPathToSavedPhotosAlbum([url path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

// completion handler for saving a video
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSLog(@"Finished saving with error: %@", error.localizedDescription);
    
    // remove the temp file
    NSError *err = nil;
    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&err];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
}

@end
