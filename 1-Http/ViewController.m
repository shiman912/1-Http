//
//  ViewController.m
//  1-Http
//
//  Created by qianfeng on 16/1/18.
//  Copyright © 2016年 石曼. All rights reserved.
//

#import "ViewController.h"
#import "UserModel.h"
@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataSource;

@end

@implementation ViewController
/*
 同步的请求 : 如果请求持续的时间比较长(耗时操作),界面会卡死. (在主线程里面执行)
 
 异步的请求 :做耗时操作时,不会卡死界面. (因为没有在主线程里面运行)
 
 main 程序的主线程,所有的 UI 操作都在主线程
 
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    
    //创建数组
    _dataSource = [NSMutableArray new];
    //先去请求数据
    [self loadDataSource];
    //创建
     [self createTabview];
    
}
//
- (void)loadDataSource {

    //发起一个同步请求
    
    // http://10.0.8.8/sns/my/user_list.php
    
    // 用NSURL表示一个 url
    NSURL *url = [NSURL URLWithString:@"http://10.0.8.8/sns/my/user_list.php"];
    
    //创建一个请求
    /*
     第一个参数 : 是 NSURL
     第二个参数 : 缓存策略   NSURLRequestUseProtocolCachePolicy 如果数据有更新的话,直接返回最新的数据.如果没有更新,就不返回(返回本地缓存的). 一般用这个
     
     NSURLRequestReloadIgnoringLocalCacheData = 1, 忽略本地数据,每次都返回最新的数据(不管你有没有更新)
     
     第三个参数 : 超时时间. 移动网络下,超时时间设置为60秒
     
     */
    NSURLRequest *urlRequest = [NSURLRequest  requestWithURL:url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    //发起请求
    //响应
    NSURLResponse *response = nil;
    //存放错误信息的.
    NSError *error = nil;
    //发起请求  (加&符号)  NSURLConnection  syn 请求
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    if (error != nil) {
        NSLog(@"请求失败,错误信息%@",error);
    }else{
        NSLog(@"请求成功,响应信息%@",response);
    }
    
    /* 如果是 xcode7 会提示请求不安全,App Transport Security. 苹果建议都用安全的 https 请求.
     解决方法:
     1.    在Info.plist中添加NSAppTransportSecurity类型Dictionary。
     2.    在NSAppTransportSecurity下添加NSAllowsArbitraryLoads类型Boolean,值设为YES
     
     */
    
    //解析 数据
    NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSLog(@"解析数据%@",jsonObj);
    //如果我们根服务器人员交流的话,要求他们返回什么样类型的数据
    NSNumber *count = jsonObj[@"count"];
    NSNumber *totalcount = jsonObj[@"totalcount"];
    NSArray *users = jsonObj[@"users"];
    
    NSLog(@"users%ld",users.count);
    
    
    for (NSDictionary *dictItem in users) {
        UserModel *user = [[UserModel alloc] init];
        user.headimage = dictItem[@"headimage"];
        user.username = dictItem[@"username"];
        user.uid = dictItem[@"uid"];
        
        [_dataSource addObject:user]; //添加到数据源中
        
    }
    
    

}
//创建 Tableview
- (void)createTabview {
    UITableView  *tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView= tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    //增加下拉刷新
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh]; //只对 tableview 能用
    
    

}
- (void)refresh:(UIRefreshControl *)sender {
    //如果在刷新
    //判断刷新控件的状态
    if (sender.isRefreshing) {
        //清空数据
        [self.dataSource removeAllObjects];
        //重新请求
        [self loadDataSource];
        //结束刷新
        [sender endRefreshing];
        //刷新界面
        [self.tableView reloadData];

    }
    
    NSLog(@"下拉刷新");
    

}
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //取出数据
        UserModel *user = self.dataSource[indexPath.row];
        //拼出图片的地址
        NSString *headImageUrlStr = [NSString stringWithFormat:@"http://10.0.8.8/sns%@",user.headimage];
       //同步的请求
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:headImageUrlStr]];
        
        cell.imageView.image = [UIImage imageWithData:data];
        
        
        cell.textLabel.text = user.username;
        
        
    }
    return cell;
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
