//
//  UITextField+PaddedTextField.h
//  RealmBarcodeScanner
//
//  Created by Shaun Anderson on 26/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaddedTextField: UITextField
@property (nonatomic) IBInspectable CGFloat topPadding;
@property (nonatomic) IBInspectable CGFloat bottomPadding;
@property (nonatomic) IBInspectable CGFloat leftPadding;
@property (nonatomic) IBInspectable CGFloat rightPadding;
-(CGRect)textRectForBounds:(CGRect)bounds;
-(CGRect)editingRectForBounds:(CGRect)bounds;
-(CGRect)placeholderRectForBounds:(CGRect)bounds;
@end
