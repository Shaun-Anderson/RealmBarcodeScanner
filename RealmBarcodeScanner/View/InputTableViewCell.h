//
//  InputTableViewCell.h
//  RealmBarcodeScanner
//
//  Created by Shaun Anderson on 27/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextField+PaddedTextField.h"

@interface InputTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PaddedTextField *inputTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
