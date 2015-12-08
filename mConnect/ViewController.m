//
//  ViewController.m
//  mConnect
//
//  Created by Brandon Withrow on 7/9/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//

#import "ViewController.h"
#import "MCStreamRequest.h"
#import "MCStreamClient.h"
#import "MCExpandableTableModel.h"
#import "MCRotationalControl.h"

@interface ViewController () <NSStreamDelegate, MCExpandableTableModelDelegate>
@property (nonatomic, strong) MCExpandableTableModel *tableModel;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ViewController

- (instancetype)initWithListCommand:(NSString *)pyList {
  self = [super init];
  if (self) {
    self.tableModel = [[MCExpandableTableModel alloc] init];
    MCStreamRequest *allObjects = [[MCStreamRequest alloc] initWithMessage:pyList];
    
    __weak typeof(self) weakSelf = self;
    allObjects.completionBlock = ^(MCStreamRequest *response) {
      __strong typeof(self) strongSelf = weakSelf;
      [strongSelf createSceneTreeWithResponse:response];
    };
    
    [[MCStreamClient sharedClient] addRequestToQueue:allObjects];
  }
  return self;
}

- (void)createSceneTreeWithResponse:(MCStreamRequest *)response {
  NSError *error;
  NSString *string = [NSString stringWithUTF8String:[response.responseData bytes]];
  NSLog(@"RECIEVED %@", string);
  if (string) {
    NSData *metOfficeData = [string dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:metOfficeData options:kNilOptions error:&error];
    if (error) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"ERROR %li", (long)error.code] message:error.domain delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles:nil];
      [alert show];
    } else {
      self.tableModel.jsonObject = jsonObject;
    }
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
  [self.view addSubview:self.tableView];
  self.tableModel.tableView = self.tableView;
  self.tableView.editing = YES;
  self.tableView.allowsSelectionDuringEditing = YES;
  self.tableModel.delegate = self;
	// Do any additional setup after loading the view, typically from a nib.
  MCRotationalControl *rotControl = [[MCRotationalControl alloc] initWithFrame:CGRectMake(0, 100, 150, 150)];
  [self.view addSubview:rotControl];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  self.tableView.frame = self.view.bounds;
}

- (void)expandableTableModel:(MCExpandableTableModel *)tableModel didSelectRowAtIndex:(NSIndexPath *)indexPath {
  MCDAGObject *selectedSet = [self.tableModel.itemsFlattened objectAtIndex:indexPath.row];
  if (!self.selectOnly) {
    NSString *pyMesage = [NSString stringWithFormat:@"bw.lsSetChildren('%@')", selectedSet.title];
    ViewController *vc = [[ViewController alloc] initWithListCommand:pyMesage];
    vc.selectOnly = YES;
    [self.navigationController pushViewController:vc
                                         animated:YES];
    
  } else {
    __weak typeof(self) weakSelf = self;
    [selectedSet getAttrsWithCompletion:^{
      __strong typeof(self) strongSelf = weakSelf;
      [strongSelf.tableView reloadData];
    }];
  }
  
  
}

@end
