//
//  VideoEditViewController.h
//  VideoEdit
//
//  Created by 卢梓源 on 2019/6/24.
//  Copyright © 2019 Garry. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditFinishViewController : UIViewController

/*
 待编辑视频的URL
 */
@property (nonatomic, strong) NSURL *videoUrl;

@property (nonatomic, strong) UIImage *image;


@end

NS_ASSUME_NONNULL_END
