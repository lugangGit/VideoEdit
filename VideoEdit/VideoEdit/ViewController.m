//
//  ViewController.m
//  VideoEdit
//
//  Created by 卢梓源 on 2019/6/24.
//  Copyright © 2019 Garry. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "EditFinishViewController.h"
#import <AVFoundation/AVTime.h>
@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIVideoEditorControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) NSURL *urlString;
@property (nonatomic, assign) BOOL isSave;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self createUI];
}

- (void)createUI {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-50, self.view.bounds.size.height/2-10, 100, 20)];
    [button setTitle:@"选择视频" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
    button.layer.borderColor = [UIColor grayColor].CGColor;
    button.layer.cornerRadius = 6;
    [button addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.imagePickerController.allowsEditing = YES;
}

- (void)clickBtn:(UIButton *)sender {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"选择视频" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"录制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectVideoFromCamera];
        
    }];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectVideoFromAlbum];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:cameraAction];
    [alertVc addAction:photoAction];
    [alertVc addAction:cancelAction];
    [self presentViewController:alertVc animated:YES completion:nil];
}

#pragma mark - 从摄像头获取视频
- (void)selectVideoFromCamera
{
    //NSLog(@"相机");
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //录制视频时长，默认10s
    self.imagePickerController.videoMaximumDuration = 1500;
    //相机类型（拍照、录像...）
    //self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
    self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
    //视频上传质量
    self.imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    //设置摄像头模式（拍照，录制视频）
    self.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - 从相册获取视频
- (void)selectVideoFromAlbum
{
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

//#pragma mark - UIImagePickerControllerDelegate
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
//    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
//
//    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
//
//    }else{
//        //如果是视频
//        NSURL *url = info[UIImagePickerControllerMediaURL];
//        //播放视频
//        self.urlString = url;
//
//        //保存视频至相册（异步线程）
//        NSString *urlStr = [url path];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
//                UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//            }
//        });
//    }
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if([mediaType isEqualToString:@"public.movie"]) {
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            
            //播放视频
            self.urlString = videoURL;
            
            UIVideoEditorController *editVC;
            // 检查这个视频资源能不能被修改
            if ([UIVideoEditorController canEditVideoAtPath:videoURL.path]) {
                editVC = [[UIVideoEditorController alloc] init];
                editVC.videoPath = videoURL.path;
                editVC.delegate = self;
            }
            [self presentViewController:editVC animated:YES completion:nil];
            
            //保存视频至相册（异步线程）
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL.path)) {
                    UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                }
            });
        }
    }];
}

#pragma mark - 编辑成功后的Video被保存在沙盒的临时目录中
- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath {
    NSLog(@"+++++++++++++++%@",editedVideoPath);
    NSURL *url = [NSURL URLWithString:editedVideoPath];
    if (!self.isSave) {
        self.isSave = !self.isSave;
        [self saveToAlbum:url];
    }
}

#pragma mark - 编辑失败后调用的方法
- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error {
    NSLog(@"%@",error.description);
}

#pragma mark - 编辑取消后调用的方法
- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 截取保存到相册
- (void)saveToAlbum:(NSURL *)url {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            NSLog(@"视频截取过程中发生错误，错误信息:%@",error.localizedDescription);
        }else{
            NSLog(@"视频截取保存成功");
            EditFinishViewController *VC = [[EditFinishViewController alloc] init];
            VC.image = [self firstFrameWithVideoURL:url];
            [self presentViewController:VC animated:YES completion:nil];
        }
        self.isSave = !self.isSave;
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 图片保存完毕的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextIn {
    
}

#pragma mark - 视频保存完毕的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextIn {
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
    }
}

#pragma mark ---- 获取图片第一帧
- (UIImage *)firstFrameWithVideoURL:(NSURL *)url{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:url.path] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouch = [event allTouches];
    UITouch *touch = [allTouch anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    int x = point.x;
    int y = point.y;
    NSLog(@"x,y == (%d, %d)", x, y);
}

@end
