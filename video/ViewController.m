//
//  ViewController.m
//  video
//
//  Created by butter on 2019/8/7.
//  Copyright © 2019 butter. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"
#import <Photos/Photos.h>
@interface ViewController ()<GPUImageMovieDelegate>

@property (nonatomic, strong) NSMutableArray <AVAsset *> *assets;

@end

typedef void (^HandleVideoCompletion) (AVAsset *videoAsset, NSError *error);

@implementation ViewController
//pendant
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    return;
    
    
    NSString *videoURL = [[NSBundle mainBundle] pathForResource:@"123" ofType:@"MP4"];
    AVAsset *asset1 = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoURL]];
    
    NSString *videoURL1 = [[NSBundle mainBundle] pathForResource:@"456" ofType:@"MP4"];
    AVAsset *asset2 = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoURL1]];
    
    NSMutableArray <AVAsset *> *assets = [@[] mutableCopy];
    [assets addObject:asset1];
    [assets addObject:asset2];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    
    UIImage *bgImage;
    
    [self genVideoWithVideoAssets:assets withPendantViews:@[imageView] bgImage:bgImage borderSize:bgImage.size completion:^(AVAsset *videoAsset, NSError *error) {
        
    }];
}

- (void)genVideoWithVideoAssets:(NSMutableArray <AVAsset *> *)assets withPendantViews:(NSArray <UIImageView *> *)pendantViews bgImage:(UIImage *)image borderSize:(CGSize)borderSize completion:(HandleVideoCompletion)completion {
    
    //视频时长排序
    NSMutableArray *tempArray = [assets mutableCopy];
    [tempArray sortUsingComparator:^NSComparisonResult(AVAsset *obj1, AVAsset *obj2) {
        int32_t comResult = CMTimeCompare(obj1.duration, obj2.duration);
        if (comResult == -1) {
            return 1;
        }
        return -1;
    }];
    
    //视频宽度排序
    NSMutableArray *tempArray1 = [assets mutableCopy];
    [tempArray1 sortUsingComparator:^NSComparisonResult(AVAsset *obj1, AVAsset *obj2) {
        AVAssetTrack *videoTrack1 = [obj1 tracksWithMediaType:AVMediaTypeVideo].firstObject;
        AVAssetTrack *videoTrack2 = [obj2 tracksWithMediaType:AVMediaTypeVideo].firstObject;
        return videoTrack1.naturalSize.width > videoTrack2.naturalSize.height;
    }];
    
    
    CGFloat maxVideoWidth = [tempArray1.firstObject tracksWithMediaType:AVMediaTypeVideo].firstObject.naturalSize.width;
    NSLog(@"最大宽度： %@", @(maxVideoWidth));
    
    CGFloat ratio = 1;
    CGFloat width = ceil(borderSize.width * 16) / 16;
    CGFloat height = ceil((borderSize.height * width / borderSize.width) / 2) * 2;
    if (maxVideoWidth > width) {
        NSInteger max = ceil(maxVideoWidth);
        while ((max % 16) != 0) {
            max++;
        }
        
        ratio = max / width;
        width = max;
        height = height * ratio;
    }
    
    borderSize = CGSizeMake(width, height);
    
     AVAsset *asset = tempArray.firstObject;
    //生成图片数组 便于生成背景视频
    Float64 seconds = CMTimeGetSeconds(asset.duration);
    NSInteger s = ceil(seconds);
    NSMutableArray *images = [@[] mutableCopy];
    for (NSInteger i = 0; i < s; ++i) {
        [images addObject:[image copy]];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *outputURL = paths[0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    outputURL = [outputURL stringByAppendingPathComponent:@"backgroundImage.mov"];
    [manager removeItemAtPath:outputURL error:nil];
    
    NSLog(@"path: %@ ", outputURL);
    [self writeImageAsMovie:images toPath:outputURL size:borderSize completion:^(AVAsset *videoAsset, NSError *error) {
        if (!error && videoAsset) {
            [assets addObject:videoAsset];
            [self vediosMergeWithAssets:assets withPandentViews:pendantViews withRatio:ratio completion:^(AVAsset *videoAsset, NSError *error) {
                
            }];
           
        }
    }];
}

- (void)vediosMergeWithAssets:(NSMutableArray <AVAsset *> *)assets withPandentViews:(NSArray <UIImageView *> *)pandentViews withRatio:(CGFloat)ratio completion:(HandleVideoCompletion)completion {
    
    for (AVAsset *asset in assets) {
        AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        NSLog(@"每个视频的尺寸：%@", NSStringFromCGSize(videoTrack.naturalSize));
    }
    
    //背景视频在最后一个 取出背景视频
    AVAsset *backgroundAsset = assets.lastObject;
    AVAssetTrack *videoTrack = [backgroundAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    NSError *error = nil;
    //创建一个容器  并且插入一个时间段的视频、音频轨道  0：嵌入视频 1：背景视频 2：嵌入视频的音频
    AVMutableComposition *compostion = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTracks[assets.count + 1]; // + 1 是增加一条音频轨道
    for (NSInteger i = 0; i < assets.count; ++i) {
        AVAsset *asset = assets[i];
        AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        compositionVideoTracks[i] = [compostion addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTracks[i] insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:&error];
    }
    
    //插入音频轨道
    AVAsset *intoAsset = assets.firstObject;
    AVAssetTrack *audioTrack = [intoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    AVMutableCompositionTrack *audioCompositionTrack = compositionVideoTracks[assets.count];
    audioCompositionTrack = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, intoAsset.duration) ofTrack:audioTrack atTime:kCMTimeZero error:&error];
    
    //第一个视频的尺寸 为最终绘制尺寸
    CGSize renderSize = videoTrack.naturalSize;
    NSMutableArray *layerInstructions = [@[] mutableCopy];
    
    for (NSInteger i = 0; i < assets.count; ++i) { //只有2个视频
        AVAsset *asset = assets[i];
        AVAssetTrack *currentVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        if (i == assets.count - 1) { //背景视频
            AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction
                                                                           videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[i]];
            [layerInstruction setTransform:currentVideoTrack.preferredTransform atTime:kCMTimeZero];
            [layerInstructions addObject:layerInstruction];
            continue;
        }
        
        for (NSInteger k = 0; k < pandentViews.count; ++k) { //嵌入视频
            if ([pandentViews[k] isKindOfClass:[UIImageView class]]) {
                UIImageView *videoEleView = (UIImageView *)pandentViews[k];
                AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction
                                                                               videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[i]];
                CGRect rect = videoEleView.frame; //控件在画布上的大小
                CGSize videoSize = currentVideoTrack.naturalSize;  //子视频大小
                
                CGFloat scaleX = rect.size.width / videoSize.width * ratio;
                CGFloat x = rect.origin.x * ratio;
                CGFloat y = rect.origin.y * ratio;
                
                CGAffineTransform t = CGAffineTransformMake(scaleX, 0, 0, scaleX, x, y);
                [layerInstruction setTransform:t atTime:kCMTimeZero];
                [layerInstructions addObject:layerInstruction];
            }
        }
    }
    
    AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, backgroundAsset.duration);
    videoCompositionInstruction.layerInstructions = layerInstructions;
    
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.renderSize = renderSize;
    mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    mutableVideoComposition.instructions = @[videoCompositionInstruction];
    
    CALayer *parentLayer = [[CALayer alloc] init];
    parentLayer.contentsScale = [UIScreen mainScreen].scale;
    parentLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
    
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, renderSize.width, renderSize.height);
    videoLayer.contentsScale = [UIScreen mainScreen].scale;
    [parentLayer addSublayer:videoLayer];
    
    for (NSInteger i = 0; i < pandentViews.count; ++i) {
        if ([pandentViews[i] isKindOfClass:[UIImageView class]]) {
            UIImageView *sticketEleView = (UIImageView *)pandentViews[i];
            
            CALayer *imageLayer = [CALayer layer];
            imageLayer.frame = CGRectMake(sticketEleView.frame.origin.x * ratio,
                                          (renderSize.height - sticketEleView.frame.size.height * ratio - sticketEleView.frame.origin.y * ratio),
                                          sticketEleView.frame.size.width * ratio,
                                          sticketEleView.frame.size.height * ratio);
            [imageLayer setContents:(id)[sticketEleView.image CGImage]];
            [parentLayer addSublayer:imageLayer];
        }
    }
    
    mutableVideoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    NSString *outputURL = nil;//[self genVideoPathWithName:@"output.mov"];
    NSLog(@"path: %@", outputURL);
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:compostion presetName:AVAssetExportPresetHighestQuality];
    exporter.videoComposition = mutableVideoComposition;
    exporter.outputURL = [NSURL fileURLWithPath:outputURL];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (exporter.status == AVAssetExportSessionStatusCompleted) {
            NSURL *url = [NSURL fileURLWithPath:outputURL];
            [[PHPhotoLibrary sharedPhotoLibrary]  performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    AVAsset *asset = [AVAsset assetWithURL:url];
                    completion(asset, nil);
                } else {
                    completion(nil, error);
                }
            }];
        } else {
            completion(nil, exporter.error);
        }
    }];
}

#pragma mark 图片转为视频
- (void)writeImageAsMovie:(NSArray *)array toPath:(NSString*)path size:(CGSize)size completion:(HandleVideoCompletion)completion {
    NSError *error = nil;
    // FIRST, start up an AVAssetWriter instance to write your video
    // Give it a destination path (for us: tmp/temp.mov)
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                         outputSettings:videoSettings];
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                                                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    
    //Start a SESSION of writing.
    
    // After you start a session, you will keep adding image frames
    
    // until you are complete - then you will tell it you are done.
    
    [videoWriter startWriting];
    // This starts your video at time = 0
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    CVPixelBufferRef buffer = NULL;
    // This was just our utility class to get screen sizes etc.
    CMTime presentTime;
    for (NSInteger i = 0; i < array.count; ++i) {
        if(writerInput.readyForMoreMediaData){
            if (i == 0) {
                presentTime = CMTimeMake(0, 30);
            } else {
                presentTime = CMTimeMake(30 * i, 30);
            }
            
            buffer = [self pixelBufferFromCGImage:[[array objectAtIndex:i] CGImage] withSize:size];
            [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime]; //异步添加 延时0.05秒
            [NSThread sleepForTimeInterval:0.05];
            CMTimeShow(presentTime);
        }
    }
    
    [writerInput markAsFinished];
    [videoWriter finishWritingWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (videoWriter.status != AVAssetWriterStatusFailed && videoWriter.status == AVAssetWriterStatusCompleted)  {
                NSURL *videoTempURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", path]];
                [[PHPhotoLibrary sharedPhotoLibrary]  performChanges:^{
                    [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoTempURL];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        AVAsset *asset = [AVAsset assetWithURL:videoTempURL];
                        completion(asset, nil);
                    } else {
                        completion(nil, error);
                    }
                }];
            } else {
                completion(nil, videoWriter.error);
            }
        });
        
    }];
    
    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef) image withSize:(CGSize)size{
    // This again was just our utility class for the height & width of the
    // incoming video (640 height x 480 width)
    int width = size.width;
    int height = size.height;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width,
                                          height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    NSParameterAssert(pxdata != NULL);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, width,
                                                 height, 8, 4*width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    
    NSParameterAssert(context);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    CGContextDrawImage(context, CGRectMake(0, 0, width,
                                           
                                           height), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

@end
