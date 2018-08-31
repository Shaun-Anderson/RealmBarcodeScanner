//
//  Form.h
//  RealmBarcodeScanner
//
//  Created by Shaun Anderson on 27/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#ifndef Form_h
#define Form_h

typedef enum {
    Text,
    Image,
    Stepper
} InputTypeFlag;

@interface FormInput: NSObject
@property NSString *inputName;
@property InputTypeFlag typeFlag;
@end

@interface FormSection: NSObject
@property NSString *sectionName;
@property NSMutableArray<FormInput *> *inputs;
- (void)addTextField:(NSString*)name;
- (void)addStepper:(NSString *)name;
@end

@interface Form: NSObject
@property NSMutableArray<FormSection *> *sections;
- (void)addSection:(NSString*)sectionName;
- (void)addTextField:(NSString*)name;
- (void)addStepper:(NSString *)name;
@end

@interface FormTextInput: FormInput
@property NSString *input;
@end

@interface FormStepperInput: FormInput
@property NSInteger *amount;
@end

#endif /* Form_h */
