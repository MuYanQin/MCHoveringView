//
//  Demo1ViewController.m
//  MCHoveringView
//
//  Created by qinmuqiao on 2019/3/27.
//  Copyright © 2019年 MuYaQin. All rights reserved.
//

#import "Demo1ViewController.h"

@interface Demo1ViewController ()<UITableViewDelegate,UITableViewDataSource,QQtableViewRequestDelegate>
@property (nonatomic , strong) NSMutableArray * dataArray;
@property (nonatomic , strong) NSLock * lock;
@end

@implementation Demo1ViewController

-  (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArray = @[@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@""].mutableCopy;
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"DEMO";
    [self.view addSubview:self.tableView];
}
- (void)viewDidAppear:(BOOL)animated
{
}
//这里是必须存在的方法 传递tableView的偏移量
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tableView.scrollViewDidScroll) {
        self.tableView.scrollViewDidScroll(self.tableView);
    }
}
- (void)QQtableView:(QQtableView *)QQtableView requestFailed:(NSError *)error
{
    
}
-(void)QQtableView:(QQtableView *)QQtableView isPullDown:(BOOL)PullDown SuccessData:(id)SuccessData
{
    
    if (self.dataArray.count >0) {
        self.dataArray = @[].mutableCopy;
    }else{
        self.dataArray = @[@"",@"",@""].mutableCopy;
    }
    //处理返回的SuccessData 数据之后刷新table
    [self.tableView reloadData];
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
        /**
         注意⚠️这里初始化QQtableView  千万不能使用[[QQtableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50 - 64)];
         这样初始化的话会造成走俩次创建方法 生成俩个tableView对象。
            具体原因不详，初步猜测是因为在ViewController中的self.demo1.tableView调用懒加载的时候initWithFrame。给的frame不为空
         view内部渲染涂层 ，没有及时的返回实例化对象 所以  [self.view addSubview:self.tableView];的时候_tableView还是nil所以又走了一次
         */
        _tableView = [[QQtableView alloc]initWithFrame:CGRectZero];
        //这里frame的高减了 64 是减去了nav的高度。  50 是PageView的中的titleView的高度就是搜索 、认证、我的 所处view的高度 具体请款视视图而定
        _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50 - 64);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.RequestDelegate = self;
        //table是否有刷新
        _tableView.isHasHeaderRefresh = NO;
        _tableView.emptyView.imageName = @"noList";
        _tableView.emptyView.imageSize = CGSizeMake(90, 90);
        _tableView.emptyView.hintText = @"暂无数据";
        _tableView.emptyView.hintTextFont = [UIFont systemFontOfSize:15 weight:(UIFontWeightMedium)];
        _tableView.emptyView.hintTextColor = [UIColor redColor];
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
