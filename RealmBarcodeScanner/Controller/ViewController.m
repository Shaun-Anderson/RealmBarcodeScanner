//
//  ViewController.m
//  BarcadeScanner
//
//  Created by Shaun Anderson on 21/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import "ViewController.h"
#import <ImageIO/CGImageProperties.h>
#import <Realm/Realm.h>
#import "DatabaseObject.h"

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    //__weak IBOutlet UIView *InformationView;
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UIView *_highlightView;
    UILabel *_label;
    UILabel *_brightnessLevel;
    UIView *_saveView;
    double brightness;
    double lumaThreshold;
    //NSLayoutConstraint *informationViewTopConstraint;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create UI
    
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    _highlightView.layer.cornerRadius = 30;
    [self.view addSubview:_highlightView];
    
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(0, 50, self.view.bounds.size.width, 40);
    button.backgroundColor = UIColor.whiteColor;
    [button setTitle:@"OPEN CREATE" forState:normal];
    [button setTitleColor:UIColor.blackColor forState:normal];
    [button addTarget:self action:@selector(moveToCreate) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    
    [self setUpBarcodeReader];

    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_label];

}

-(void)moveToCreate {
    NSLog(@"MOVEDD");
    [self performSegueWithIdentifier:@"moveToCreate" sender:self];
}

// MARK: - Setup

- (void)setUpBarcodeReader {
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
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
    
}

- (void)setupMetaCapture {
    //-- Create the output for the capture session.
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES]; // Probably want to set this to NO when recording
    
    //-- Set to YUV420.
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                                             forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; // Necessary for manual preview
    
    // Set dispatch to be on the main thread so OpenGL can do things with the data
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    

    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
}

- (void)setupAVCapture {
    
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES]; // Probably want to set this to NO when recording
    
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                                             forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; // Necessary for manual preview
    
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [_session addOutput:dataOutput];

}

- (void)itemFound:(NSString *)itemString
{
    // If object already exists then show alert
    if ([DatabaseObject objectsWhere:@"metaDataString = %@", itemString].count != 0) {
        NSLog(@"Object already exists");
        // TODO: Create alert for existing.
        return;
    }
    
    UIAlertController* foundAlert = [UIAlertController alertControllerWithTitle:@"Unknown object found" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* addAction = [UIAlertAction actionWithTitle:@"Add to database" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [self moveToCreate];
                                                           }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             self->_highlightView.frame = CGRectZero;
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

// MARK: - Output


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
