//
//  FormStepperTableViewCell.h
//  RealmBarcodeScanner
//
//  Created by Shaun Anderson on 31/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextField+PaddedTextField.h"

@interface FormStepperTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PaddedTextField *stepperValueField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@end
