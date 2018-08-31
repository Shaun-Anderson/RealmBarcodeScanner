//
//  CreateViewController.m
//  RealmBarcodeScanner
//
//  Created by Shaun Anderson on 26/8/18.
//  Copyright © 2018 Shaun Anderson. All rights reserved.
//

#import "CreateViewController.h"
#import "InputTableViewCell.h"
#import "FormStepperTableViewCell.h"
#import "DatabaseObject.h"
#import "Form.h"

@interface CreateViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CreateViewController

DatabaseObject *newObject;
Form* form;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    form = [[Form alloc] init];
    [form addSection:@"Input"];
    [form addTextField:@"Name"];
    [form addTextField:@"Description"];
    [form addSection:@"Next"];
    [form addStepper:@"Amount"];
    
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
    NSString *stepperCellIdentifier = @"formStepperCell";
    
    switch (form.sections[indexPath.section].inputs[indexPath.row].typeFlag) {
        case Text:
        {
            InputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            
            if (cell == nil) {
                cell = [[InputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            }
            
            cell.titleLabel.text = form.sections[indexPath.section].inputs[indexPath.row].inputName;
            return cell;
        }
            
        case Stepper:
        {
            FormStepperTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:stepperCellIdentifier];
            
            if (cell == nil) {
                cell = [[FormStepperTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stepperCellIdentifier];
            }
            
            cell.titleLabel.text = form.sections[indexPath.section].inputs[indexPath.row].inputName;
            return cell;
        }
            
        default:
        {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            return cell;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return form.sections[section].inputs.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return form.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return form.sections[section].sectionName;
}

@end
