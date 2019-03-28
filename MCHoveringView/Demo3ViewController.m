//
//  Demo3ViewController.m
//  MCHoveringView
//
//  Created by qinmuqiao on 2019/3/27.
//  Copyright © 2019年 MuYaQin. All rights reserved.
//

#import "Demo3ViewController.h"
#import "QQTableView/QQtableView.h"

@interface Demo3ViewController ()<UITableViewDelegate,UITableViewDataSource,QQtableViewRequestDelegate>
@property (nonatomic , strong) NSMutableArray * dataArray;

@end

@implementation Demo3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArray = [NSMutableArray array];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"DEMO";
    self.dataArray = @[@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@""].mutableCopy;
    [self.view addSubview:_tableView];

    //请求数据
//    [self.tableView setUpWithUrl:@"/getData/getist" Parameters:@{} formController:self];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tableView.scrollViewDidScroll) {
        self.tableView.scrollViewDidScroll(self.tableView);
    }
}
- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"cell"];
    }
    cell.detailTextLabel.text = @(indexPath.row).stringValue;
    return cell;
}
- (QQtableView *)tableView
{
    if (!_tableView) {
        _tableView = [[QQtableView alloc]initWithFrame:CGRectZero];
        _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50 - 64);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.RequestDelegate = self;
        //table是否有刷新
        _tableView.isHasHeaderRefresh = YES;
        _tableView.emptyView.imageName = @"noList";
        _tableView.emptyView.imageSize = CGSizeMake(90, 90);
        _tableView.emptyView.hintText = @"暂无数据";
        _tableView.emptyView.hintTextFont = [UIFont systemFontOfSize:15 weight:(UIFontWeightMedium)];
        _tableView.emptyView.hintTextColor = [UIColor redColor];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
