//
//  UITextField+PaddedTextField.m
//  RealmBarcodeScanner
//
//  Created by Shaun Anderson on 26/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import "UITextField+PaddedTextField.h"

@implementation PaddedTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    UIEdgeInsets paddedInsets = UIEdgeInsetsMake(_topPadding, _leftPadding, _bottomPadding, _rightPadding);
    return UIEdgeInsetsInsetRect(bounds, paddedInsets);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    UIEdgeInsets paddedInsets = UIEdgeInsetsMake(_topPadding, _leftPadding, _bottomPadding, _rightPadding);
    return UIEdgeInsetsInsetRect(bounds, paddedInsets);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    UIEdgeInsets paddedInsets = UIEdgeInsetsMake(_topPadding, _leftPadding, _bottomPadding, _rightPadding);
    return UIEdgeInsetsInsetRect(bounds, paddedInsets);
}

@end
