//
//  DatabaseObject.h
//  BarcodeScanner
//
//  Created by Shaun Anderson on 25/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import <Realm/Realm.h>

#ifndef DatabaseObject_h
#define DatabaseObject_h

@interface DatabaseObject : RLMObject
@property NSString *name;
@property NSString *metaDataString;
@property NSData *photoData;
@end

#endif /* DatabaseObject_h */
