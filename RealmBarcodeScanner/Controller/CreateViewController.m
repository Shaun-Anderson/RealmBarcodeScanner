//
//  CreateViewController.m
//  RealmBarcodeScanner
//
//  Created by Shaun Anderson on 26/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import "CreateViewController.h"
#import "DatabaseObject.h"
#import <Formed/Formed.h>

@implementation CreateViewController

DatabaseObject *newObject;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.form = [[Form alloc] init];
    
    FormSegmentedControl *typeSelector = [self.form addSegmentedControl];
    [typeSelector addSegment:@"|"];
    [typeSelector addTextField:@"TextExample"];
    [typeSelector addSegment:@"||"];
    [typeSelector addTextField:@"OtherTextExample"];
    [typeSelector addTextField:@"OtherTextExample"];

    [self.form addHeader:@"Other elements"];
    [self.form addStepper:@"Stepper Example"];
    [self.form addSwitch:@"Switch Example"];

    [self.form addSwitch:@"Switch Example"];
    [self.form addSwitch:@"Switch Example"];
    [self.form addSwitch:@"Switch Example"];
    [self.form addSwitch:@"Switch Example"];
    [self.form addSwitch:@"Switch Example"];
    [self.form addTextField:@"Bottom"];
    [self.form addSwitch:@"Switch Example"];
    
    [self.form addSwitch:@"Switch Example"];
    [self.form addSwitch:@"Switch Example"];
    [self.form addTextField:@"Bottom"];
    
    FormSegmentedControl *otherType = [self.form addSegmentedControl];
    [otherType addSegment:@"1"];
    [otherType addTextField:@"TextExample"];
    [otherType addTextField:@"TextExample"];
    [otherType addSegment:@"2"];
    [otherType addTextField:@"hiiiii"];
    [otherType addTextField:@"TextExample"];

    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)saveButtonPressed:(id)sender {
    
}

- (IBAction)cancelButtonPressed {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)addItemToRealm:(NSString*)itemName MetaData:(NSString*)itemMetaData{
    DatabaseObject *newObject = [[DatabaseObject alloc] init];
    newObject.name = itemName;
    newObject.metaDataString = itemMetaData;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addObject:newObject];
    }];
    
}


@end
