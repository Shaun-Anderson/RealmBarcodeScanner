//
//  CreateViewController.m
//  RealmBarcodeScanner
//
//  Created by Shaun Anderson on 26/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import "CreateViewController.h"
#import "InputTableViewCell.h"
#import "DatabaseObject.h"

@interface CreateViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    _tableView.delegate = self;
    _tableView.dataSource = self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveButtonPressed:(id)sender {
    
}

- (IBAction)cancelButtonPressed {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)addItemToRealm:(NSString*)itemName MetaData:(NSString*)itemMetaData{
    DatabaseObject *newObject = [[DatabaseObject alloc] init];
    newObject.name = itemName;
    newObject.metaDataString = itemMetaData;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addObject:newObject];
    }];
    
}

// MARK: - TableView Delegate/DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"inputCell";
    
    InputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[InputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    //cell.textLabel.text = [objects objectAtIndex:indexPath.row].name;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"INPUT";
}

@end
