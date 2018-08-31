//
//  Form.m
//  RealmBarcodeScanner
//
//  Created by Shaun Anderson on 27/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Form.h"

@implementation Form

- (instancetype)init {
    if (self = [super init]) {
        _sections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    _sections = nil;
}

-(NSString*)getValue:(NSString *)inputFieldName {
    NSString *returnValue = nil;
    for (int i = 0; i < _sections.count; i++) {
        for (int j = 0; j < _sections[i].inputs.count; j++) {
            if (_sections[i].inputs[j].inputName == inputFieldName) {
                switch (_sections[i].inputs[j].typeFlag) {
                    case Text:
                    {
                        FormTextInput *newText = (FormTextInput *) _sections[i].inputs[j];
                        returnValue = newText.input;
                        break;
                    }
                    default:
                        break;
                }
            }
        }
    }
    return returnValue;
}

-(void)addSection:(NSString *)sectionName {
    FormSection *newSection = [[FormSection alloc] init];
    newSection.sectionName = sectionName;
    [_sections addObject:newSection];
}

- (void)addTextField:(NSString *)name {
    FormSection *section = [_sections objectAtIndex:_sections.count-1];
    [section addTextField:name];
}

- (void)addStepper:(NSString *)name {
    FormSection *section = [_sections objectAtIndex:_sections.count-1];
    [section addStepper:name];
}
@end

@implementation FormSection

- (instancetype)init {
    if (self = [super init]) {
        _inputs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addTextField:(NSString*)name {
    FormTextInput *newText = [[FormTextInput alloc] init];
    newText.inputName = name;
    newText.typeFlag = Text;
    [_inputs addObject:newText];
}

- (void)addStepper:(NSString*)name {
    FormStepperInput *newStepper = [[FormStepperInput alloc] init];
    newStepper.inputName = name;
    newStepper.typeFlag = Stepper;
    [_inputs addObject:newStepper];
}

@end

@implementation FormInput
@end

@implementation FormTextInput
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.typeFlag = Text;
    }
    return self;
}
@end

@implementation FormStepperInput
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.typeFlag = Stepper;
    }
    return self;
}
@end
