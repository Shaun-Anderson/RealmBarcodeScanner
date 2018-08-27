//
//  InventoryViewController.m
//  RealmBarcodeScanner
//
//  Created by Shaun Anderson on 26/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import "InventoryViewController.h"
#import <Realm/Realm.h>
#import "DatabaseObject.h"

@interface InventoryViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation InventoryViewController

NSArray *tableData;
RLMResults<DatabaseObject *> *objects;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RLMRealm *realm = [RLMRealm defaultRealm]; // Create realm pointing to default file
    objects = [DatabaseObject allObjects];
    NSLog(@"%lu", (unsigned long)objects.count);

    // Do any additional setup after loading the view.
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: - TableView Delegate/DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [objects objectAtIndex:indexPath.row].name;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return objects.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

@end
