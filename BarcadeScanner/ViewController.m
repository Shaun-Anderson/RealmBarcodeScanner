//
//  ViewController.m
//  BarcadeScanner
//
//  Created by Shaun Anderson on 21/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import "ViewController.h"
#import <ImageIO/CGImageProperties.h>

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    __weak IBOutlet UIView *InformationView;
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UIView *_highlightView;
    UILabel *_label;
    UIView *_saveView;
    double brightness;
    double lumaThreshold;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    InformationView.layer.cornerRadius = 20;
    InformationView.translatesAutoresizingMaskIntoConstraints = false;
    
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    _highlightView.layer.cornerRadius = 30;
    [self.view addSubview:_highlightView];
    
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"(none)";
    [self.view addSubview:_label];
    
    // Set new things
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [_session beginConfiguration];
    [_session setSessionPreset:AVCaptureSessionPreset1920x1080];
    

    [self setupAVCapture];
    [self setupMetaCapture];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [_session commitConfiguration];
    [_session startRunning];
    
    [self.view.layer addSublayer:_prevLayer];
    [self.view bringSubviewToFront:InformationView];
    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_label];
    
    // Constraints
    
    NSLayoutConstraint *informationViewLeading = [NSLayoutConstraint
                                                  constraintWithItem:InformationView attribute:NSLayoutAttributeLeading
                                                  relatedBy:NSLayoutRelationEqual toItem:self.view attribute:
                                                  NSLayoutAttributeLeading multiplier:1.0 constant:50];
    
    
    NSLayoutConstraint *informationViewTrailing= [NSLayoutConstraint
                                                  constraintWithItem:InformationView attribute:NSLayoutAttributeTrailing
                                                  relatedBy:NSLayoutRelationEqual toItem:self.view attribute:
                                                  NSLayoutAttributeTrailing multiplier:1.0 constant:50];
    
    [self.view addConstraints:@[informationViewLeading, informationViewTrailing]];

}

- (void)setupMetaCapture {
    NSError *error = nil;
    //-- Create the output for the capture session.
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES]; // Probably want to set this to NO when recording
    
    //-- Set to YUV420.
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                                             forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; // Necessary for manual preview
    
    // Set dispatch to be on the main thread so OpenGL can do things with the data
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
}

- (void)setupAVCapture {
    
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if(error)
        assert(0);
    
    [_session addInput:input];
    
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES]; // Probably want to set this to NO when recording
    
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                                             forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; // Necessary for manual preview
    
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [_session addOutput:dataOutput];

}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {
            [self itemFound:detectionString];
            [_session stopRunning];
            break;
        }
        else
            _label.text = @"(none)";
    }
    
    _highlightView.frame = highlightViewRect;
}

- (void)itemFound:(NSString *)itemString
{
    UIAlertController* foundAlert = [UIAlertController alertControllerWithTitle:@"Unknown object found" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* addAction = [UIAlertAction actionWithTitle:@"Add to database" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               //Code to unfollow
                                                           }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             _highlightView.frame = CGRectZero;
                                                             [_session startRunning];

                                                         }];
    
    [foundAlert addAction:addAction];
    [foundAlert addAction:cancelAction];
    [foundAlert setModalPresentationStyle:UIModalPresentationPopover];
    
    UIPopoverPresentationController *popPresenter = [foundAlert popoverPresentationController];
    popPresenter.sourceView = self.view;
    popPresenter.sourceRect = CGRectMake(0,0,1.0,1.0);
    [self presentViewController:foundAlert animated:YES completion:nil];
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,
                                                                 sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc]
                              initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata
                                   objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    brightness = [[exifMetadata
                            objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    float oldMin = -4.639957; // dark
    float oldMax = 4.639957; // light
    if (brightness > oldMax) oldMax = brightness; // adjust oldMax if brighter than expected oldMax
    
    lumaThreshold = ((brightness - oldMin) * ((3.0 - 1.0) / (oldMax - oldMin))) + 1.0;
    
    NSLog(@"brightnessValue %f", brightness);
    NSLog(@"lumaThreshold %f", lumaThreshold);
}

@end
