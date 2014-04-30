//
//  SecondViewController.m
//  PullToRefreshView
//
//  Created by Arien Lau on 14-3-10.
//  Copyright (c) 2014年 Arien Lau. All rights reserved.
//

#import "SecondViewController.h"
#import "ALPullToRefreshView.h"

@interface SecondViewController () <UITableViewDataSource, UITableViewDelegate, ALPullToRefreshViewDelegate>
{
    NSMutableArray *_dataArray;
    BOOL _isLoading;
    ALPullToRefreshView *_ALPullDownView;
    ALPullToRefreshView *_ALPullUpView;
    UITableView *_tableView;
}

@end

@implementation SecondViewController

//- (void)dealloc {
//    NSLog(@"%s", __FUNCTION__);
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _dataArray = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i < 10; i++) {
            [_dataArray addObject:[NSString stringWithFormat:@"This is %d rows", i]];
        }
        _isLoading = NO;
    }
    return self;
}

NSInteger DeviceSystemVersion()
{
    static NSInteger version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
    });
    return version;
}
#define iOS_7 (DeviceSystemVersion() >= 7)

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    if (iOS_7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        _tableView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64);
        _tableView.contentInset = UIEdgeInsetsZero;
    }
    
    [self.view addSubview:_tableView];
    [_tableView reloadData];
    
    _ALPullDownView = [[ALPullToRefreshView alloc] initWithFrame:CGRectMake(0, -CGRectGetHeight(_tableView.frame), CGRectGetWidth(_tableView.frame), CGRectGetHeight(_tableView.frame)) imageName:@"grayArrow.png" textColor:[UIColor blackColor] viewStyle:ALViewStylePullDown];
    _ALPullDownView.delegate = self;
//    _ALPullDownView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_tableView addSubview:_ALPullDownView];
    
    _ALPullUpView = [[ALPullToRefreshView alloc] initWithFrame:CGRectMake(0, _tableView.contentSize.height, CGRectGetWidth(_tableView.frame), CGRectGetHeight(_tableView.frame)) imageName:@"grayArrow.png" textColor:nil viewStyle:ALViewStylePullUp];
    _ALPullUpView.delegate = self;
    [_tableView addSubview:_ALPullUpView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [_dataArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - ALPullToRefreshViewDelegate
- (BOOL)ALPullToRefreshViewIsLoading:(ALPullToRefreshView *)view
{
    return _isLoading;
}

- (void)ALPullToRefreshViewDidRefresh:(ALPullToRefreshView *)view
{
    dispatch_queue_t myqueue = dispatch_queue_create("com.companyname.userqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myqueue, ^{
        _isLoading = YES;
        NSUInteger num = _dataArray.count;
        for (NSUInteger i = num; i < 10 + num; i++) {
#if __LP64__
            NSString *str = [NSString stringWithFormat:@"这是第%lurow", i];
#else
            NSString *str = [NSString stringWithFormat:@"这是第%urow", i];
#endif
            [_dataArray addObject:str];
        }
        [NSThread sleepForTimeInterval:5];
        dispatch_async(dispatch_get_main_queue(), ^{
            _isLoading = NO;
            [_tableView reloadData];
            [_ALPullDownView ALPullToRefreshViewDidFinishLoading:_tableView];
            [_ALPullUpView ALPullToRefreshViewDidFinishLoading:_tableView];
        });
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_ALPullDownView ALPullToRefreshViewDidScroll:scrollView];
    
    [_ALPullUpView ALPullToRefreshViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_ALPullDownView ALPullToRefreshViewDidEndDrag:scrollView];
    
    [_ALPullUpView ALPullToRefreshViewDidEndDrag:scrollView];
}

@end
