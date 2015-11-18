//
//  AKScanCodeViewController.m
//  AKScanCodeViewController
//
//  Created by Aston on 15/11/17.
//  Copyright © 2015年 Aston. All rights reserved.
//
#import "UIView+AutoLayout.h"
#import <AVFoundation/AVFoundation.h>
#import "AKScanCodeViewController.h"

//debugLog
#ifdef DEBUG
# define DebugLog(fmt, ...) NSLog((@"\n[文件名:%s]\n""[函数名:%s]\n""[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define DebugLog(...);
#endif

@interface AKScanCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL _isAnimating;
}

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, retain) UIImageView * line;

//test
//@property (nonatomic, weak) UIImageView *imageView;

@end





@implementation AKScanCodeViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"二维码扫描";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_device == nil) {
        [self setupCamera];
    }else{
        [self beginReading];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self endReading];
}

- (void)dealloc
{
    DebugLog(@"");
}



#pragma mark -
#pragma mark ---------SetUP

- (void)setupUI
{
    
    //框框之外的黑色蒙版
    UIColor *ccolor =[[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    
    //使用MaskLayer作为蒙版
    UIView *blackView = [[UIView alloc] initWithFrame:self.view.bounds];
    blackView.backgroundColor = ccolor;
    blackView.userInteractionEnabled = NO;
    [self.view addSubview:blackView];
    
    //ImageView Frame
    CGRect imageFrame = CGRectMake( self.view.bounds.size.width/2.f - 300/2.f, self.view.center.y - 64/2.f - 300/2.f, 300.f, 300.f);
    
    CGRect innerFrame = CGRectInset(imageFrame, 12, 12);
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    UIBezierPath *imageViewPath = [[UIBezierPath bezierPathWithRoundedRect:innerFrame cornerRadius:5] bezierPathByReversingPath];
    [path appendPath:imageViewPath];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    blackView.layer.mask = maskLayer;
    
    
    UILabel * labIntroudction= [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.numberOfLines=2;
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.textAlignment  = NSTextAlignmentCenter;
    labIntroudction.font = [UIFont systemFontOfSize:14];
    labIntroudction.text=@"将二维码放入框内，即可自动扫描";
    [self.view addSubview:labIntroudction];
    
    
    //框框 the frame of the square
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 100, 300, 300)];
    imageView.image = [UIImage imageNamed:@"pick_bg_scan"];
    [self.view addSubview:imageView];


    
    
    
    //扫描的横线
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(50, 110, 220, 2)];
    _line.image = [UIImage imageNamed:@"line_scan.png"];
    [self.view addSubview:_line];
    
    
    
    
    [imageView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.view];
    [imageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.view withOffset:0];
    [imageView autoSetDimension:ALDimensionHeight toSize:300.f];
    [imageView autoSetDimension:ALDimensionWidth toSize:300.f];
    
    //四个View 做覆盖层的布局
    /*
     CGFloat dex = 12.f;

    UIView *coverTop = [[UIView alloc] init];
    coverTop.backgroundColor = ccolor;
    coverTop.userInteractionEnabled = NO;
    [self.view addSubview:coverTop];
    
    UIView *coverBottom = [[UIView alloc] init];
    coverBottom.backgroundColor = ccolor;
    coverBottom.userInteractionEnabled = NO;
    [self.view addSubview:coverBottom];
    
    UIView *coverLeft = [[UIView alloc] init];
    coverLeft.backgroundColor = ccolor;
    coverLeft.userInteractionEnabled = NO;
    [self.view addSubview:coverLeft];
    
    UIView *coverRight = [[UIView alloc] init];
    coverRight.backgroundColor = ccolor;
    coverRight.userInteractionEnabled = NO;
    [self.view addSubview:coverRight];
    
    [coverTop autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];
    [coverTop autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [coverTop autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    [coverTop autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:imageView withOffset:dex];
    
    
    [coverBottom autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:imageView withOffset:-dex];
    [coverBottom autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [coverBottom autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    [coverBottom autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view withOffset:100];
    
    [coverLeft autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:imageView withOffset:dex];
    [coverLeft autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    [coverLeft autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:imageView withOffset:dex];
    [coverLeft autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:imageView withOffset:-dex];
    
    [coverRight autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:imageView withOffset:dex];
    [coverRight autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:imageView withOffset:-dex];
    [coverRight autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    [coverRight autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:imageView withOffset:-dex];
    */
    
    
    [labIntroudction autoAlignAxis:ALAxisVertical toSameAxisOfView:imageView];
    [labIntroudction autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:imageView withOffset:4.f];
    
    
    
    [_line autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:imageView withOffset:12.f];
    [_line autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:imageView withOffset:20.f];
    [_line autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:imageView withOffset:-20.f];
    [_line autoSetDimension:ALDimensionHeight toSize:2.f];

    
    
}


- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    
    
    //设置扫描兴趣点，坐标系远点在右上角，长宽互换，按照比例  参考文章 http://blog.csdn.net/lc_obj/article/details/41549469
    //即把你想要区域的frame 变成: CGRectMake(frame.y/superView.height, frame.x/superView.width, frame.height/superView.height, frame.width/superView.width)
    CGFloat viewHeight = self.view.bounds.size.height;
    CGFloat viewWidth = self.view.bounds.size.width;
    
    //ImageView的frame
    CGRect trueFrame = CGRectMake( viewWidth/2.f - 300/2.f, self.view.center.y - 64/2.f - 300/2.f, 300.f, 300.f);
    CGRect insets =CGRectMake(trueFrame.origin.y/viewHeight,trueFrame.origin.x/viewWidth,trueFrame.size.height/viewHeight,trueFrame.size.width/viewWidth);
    DebugLog(@"tureFrame %@ insets is %@ ", NSStringFromCGRect(trueFrame),NSStringFromCGRect(insets));
    [_output setRectOfInterest: insets];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    
    
    CGRect bounds = self.view.bounds;
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    [self startAnimation];
    [_session startRunning];
}



#pragma mark -
#pragma mark ---------SessionControl
// 启动session
- (void)beginReading{
    [self startAnimation];
    if (!self.session.running) {
        [self.session startRunning];
    }
}

// 关闭session
- (void)endReading{
    [self stopAnimation];
    if (self.session.running) {
        [self.session stopRunning];
        //        [self.preview removeFromSuperlayer];
    }
}





#pragma mark -
#pragma mark ---------AnimationControl
- (void)startAnimation
{
    
    if (_isAnimating) {
        return;
    }

    _isAnimating = YES;
    
    CABasicAnimation *upDonwn = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    upDonwn.duration = 2.f;
    upDonwn.repeatCount = MAXFLOAT;
    upDonwn.removedOnCompletion = NO;
    upDonwn.autoreverses = YES;
    upDonwn.toValue = @(277.f);
    
    CABasicAnimation *scalAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    scalAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    scalAnimation.duration = 0.5f;
    scalAnimation.repeatCount = MAXFLOAT;
    scalAnimation.removedOnCompletion = NO;
    scalAnimation.autoreverses = YES;
    scalAnimation.fromValue = [NSNumber numberWithFloat:.55f];
    scalAnimation.toValue = [NSNumber numberWithFloat:1.f];
    
    CAAnimationGroup *aniGroup = [CAAnimationGroup animation];
    [aniGroup setAnimations:@[upDonwn, scalAnimation]];
    aniGroup.duration = 2.f;
    aniGroup.repeatCount = MAXFLOAT;
    [self.line.layer addAnimation:aniGroup forKey:@"groupAnimation"];

    
}

- (void)stopAnimation
{
    if (_isAnimating == NO) {
        return;
    }
    
    _isAnimating = NO;
    [self.line.layer removeAllAnimations];
    self.line.layer.transform = CATransform3DIdentity;
}


#pragma mark -
#pragma mark --------- <AVCaptureMetadataOutputObjectsDelegate>

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{

    [self endReading];
    
    AVMetadataObject *metadata = [metadataObjects objectAtIndex:0];
    NSString *codeStr= nil;
    if ([metadata respondsToSelector:@selector(stringValue)]) {
        codeStr = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
    }

    if (codeStr != nil) {
        if (self.blockEndScanWithText) {
            self.blockEndScanWithText(codeStr);
            _blockEndScanWithText = nil;
        }
        [self actionPopBack];
        return;
    }
    
    DebugLog(@"唔好意系，某法思别啦~");
    
    
    
}

#pragma mark -
#pragma mark ---------Private Methods
- (void)actionPopBack
{
    [self.navigationController popViewControllerAnimated:YES];
}




@end
