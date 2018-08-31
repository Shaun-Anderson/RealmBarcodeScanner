//
//  FormStepperTableViewCell.m
//  RealmBarcodeScanner
//
//  Created by Shaun Anderson on 31/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import "FormStepperTableViewCell.h"

@implementation FormStepperTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}


- (IBAction)stepperValueChanged:(UIStepper*)sender {
    int myInt = (int)sender.value;
    _stepperValueField.text = [NSString stringWithFormat:@"%d", myInt];
}

- (IBAction)textFieldEditingChanged:(UITextField *)sender {
    _stepper.value = [sender.text doubleValue];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
