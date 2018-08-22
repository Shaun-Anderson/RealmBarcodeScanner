//
//  AppDelegate.m
//  BarcadeScanner
//
//  Created by Shaun Anderson on 21/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import "AppDelegate.h"
#import <Realm/Realm.h>

// Define your models
@interface Dog : RLMObject
@property NSString *name;
@property NSInteger age;
@end

@implementation Dog
// No need for implementation
@end

RLM_ARRAY_TYPE(Dog)

@interface Person : RLMObject
@property NSString      *name;
@property RLMArray<Dog> *dogs;
@end

@implementation Person
@end

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UIViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    [[NSFileManager defaultManager] removeItemAtURL:[RLMRealmConfiguration defaultConfiguration].fileURL error:nil];
    
    // Create a standalone object
    Dog *mydog = [[Dog alloc] init];
    
    // Set & read properties
    mydog.name = @"Rex";
    mydog.age = 9;
    NSLog(@"Name of dog: %@", mydog.name);
    
    // Realms are used to group data together
    RLMRealm *realm = [RLMRealm defaultRealm]; // Create realm pointing to default file
    
    // Save your object
    [realm beginWriteTransaction];
    [realm addObject:mydog];
    [realm commitWriteTransaction];
    
    // Query
    RLMResults *results = [Dog objectsInRealm:realm where:@"name contains 'x'"];
    
    // Queries are chainable!
    RLMResults *results2 = [results objectsWhere:@"age > 8"];
    NSLog(@"Number of dogs: %li", (unsigned long)results2.count);
    
    // Link objects
    Person *person = [[Person alloc] init];
    person.name = @"Tim";
    [person.dogs addObject:mydog];
    
    [realm beginWriteTransaction];
    [realm addObject:person];
    [realm commitWriteTransaction];
    
    // Multi-threading
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            RLMRealm *otherRealm = [RLMRealm defaultRealm];
            RLMResults *otherResults = [Dog objectsInRealm:otherRealm where:@"name contains 'Rex'"];
            NSLog(@"Number of dogs: %li", (unsigned long)otherResults.count);
        }
    });
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
