//
//  ViewController.m
//  ShortScreenThePictureDemo
//
//  Created by 唐云川 on 2017/4/25.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic,strong)UIView *clipView;
//增加成员属性，记录pan手势开始的点
@property (nonatomic, assign) CGPoint startPoint;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImage *barItemImage = [UIImage imageNamed:@"btnbg_blue.png"];
    UIBarButtonItem *barItem3 = [[UIBarButtonItem alloc] initWithImage:barItemImage style:UIBarButtonItemStyleDone target:self action:@selector(barButtonItemAction:)];
    // 自定义一个按钮
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 100, 44);
    [rightButton setTitle:@"截全图" forState:UIControlStateNormal];
    [rightButton setBackgroundColor:[UIColor orangeColor]];
    // 添加事件
    [rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barItem4 = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    // 显示在右侧
    self.navigationItem.rightBarButtonItems = @[barItem3,barItem4];
    
    // 1.初始化数据 (获取系统字库所有字体的名字)
    _dateList = [UIFont familyNames];
    
    // 2.创建表视图
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    // 设置数据源代理对象
    /*
     只要指定了数据源代理对象必须实现两个协议方法，一个是告诉表视图有多行，第二个是对应创建的单元格视图
     */
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
/*    //给tableView添加pan手势。跟踪pan手势，绘制图片剪切区域
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_tableView addGestureRecognizer:pan];
 */
}

#pragma mark - UITableViewDataSource
// 当系统要绘制单元格的时候，首先要知道当前单元格有几组，默认是1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// 告诉系统当前组有几行，也就是所，上述方法我们返回几，下面这个方法就会调用几次
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dateList.count;
}

// 为表视图创建单元格，有多少个单元格就创建多少次
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 创建单元格视图对象
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellid"];
    // 设置内容
    cell.textLabel.text = _dateList[indexPath.row];
    // 设置文本的字体
    cell.textLabel.font = [UIFont fontWithName:_dateList[indexPath.row] size:16];
    
    return cell;
}

#pragma mark -- 手势
- (void)pan:(UIPanGestureRecognizer *)pan{

    CGPoint endPoint = CGPointZero;
    if (pan.state == UIGestureRecognizerStateBegan) {
        /**开始点击时，记录手势的起点**/
        self.startPoint = [pan locationInView:_tableView];
    }else if(pan.state == UIGestureRecognizerStateChanged){
        /**当手势移动时，动态改变终点的值，并计算起点与终点之间的矩形区域**/
        endPoint = [pan locationInView:_tableView];
        //计算矩形区域的宽高
        CGFloat w = endPoint.x - self.startPoint.x;
        CGFloat h = endPoint.y - self.startPoint.y;
        //计算矩形区域的frame
        CGRect clipRect = CGRectMake(self.startPoint.x, self.startPoint.y, w, h);
        self.clipView.frame = clipRect;
    }else if (pan.state == UIGestureRecognizerStateEnded){
        /**若手势停止，将剪切区域的图片内容绘制到图形上下文中**/
        //开启位图上下文
        UIGraphicsBeginImageContextWithOptions(_tableView.bounds.size, NO, 0.0);
        //创建大小等于剪切区域大小的封闭路径
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.clipView.frame];
        //设置超出的内容不显示
        [path addClip];
        //获取绘图上下文
        CGContextRef context = UIGraphicsGetCurrentContext();
        //见图片渲染的上下文中
        [_tableView.layer renderInContext:context];
        //获取上下文中的图片
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        //关闭位图上下文
        UIGraphicsEndPDFContext();
        //移除剪切区域试图控件，并清空
        [self.clipView removeFromSuperview];
        self.clipView = nil;
        //将图片保存到相册中
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
    }
}

#pragma mark -- 右侧导航栏按钮事件
- (void)barButtonItemAction:(UIButton *)button{

    NSMutableArray *indexPaths = [NSMutableArray array];
    for(NSUInteger i = 0; i < [_tableView numberOfRowsInSection:0]; i++)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    UIImage *image = [self screenShotForIndexPaths:indexPaths];
    
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    //2.保存到对应的沙盒目录中，具体代码如下：
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"121cps.png"]];   // 保存文件的名称
    BOOL result = [UIImagePNGRepresentation(image)writeToFile: filePath    atomically:YES]; // 保存成功会返回YES
//    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
//    
//    [self.navigationController presentViewController:activityVC animated:YES completion:NULL];
}

- (void)rightButtonAction:(UIButton *)button{

    UIImage *image = [self getCapture];
    
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    //2.保存到对应的沙盒目录中，具体代码如下：
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"121cps.png"]];   // 保存文件的名称
    BOOL result = [UIImagePNGRepresentation(image)writeToFile: filePath    atomically:YES]; // 保存成功会返回YES
}

#pragma mark -
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error == nil) {
        NSLog(@"图片保存成功");
        [self popSecondAlertViewWithTitle:@"图片已保存到相册" Message:@"图片保存成功"];
    } else {
        NSLog(@"图片保存失败");
    }
}

- (UIImage*)getCapture
{
    
    UIImage* viewImage = nil;
    UITableView *scrollView = _tableView;
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, scrollView.opaque, 0.0);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        viewImage = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    return viewImage;
}



- (UIImage*)screenShotForIndexPaths:(NSArray*)indexPaths
{
    CGPoint originalOffset = _tableView.contentOffset;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(_tableView.frame), _tableView.rowHeight * [indexPaths count]), NO, 0.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //---一個一個把cell render到CGContext上
    UITableView *cell = nil;
    for(NSIndexPath *indexPath in indexPaths)
    {
        //讓該cell被正確的產生在tableView上, 之後才能在CGContext上正確的render出來
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        
        cell = (UITableView *)[_tableView cellForRowAtIndexPath:indexPath];
        [cell.layer renderInContext:ctx];
        
        //--欲在context上render的origin
        CGContextTranslateCTM(ctx, 0, _tableView.rowHeight);
        //--
    }
    //---
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    _tableView.contentOffset = originalOffset;
    
    return image;
}


- (UIView *)clipView{

    if (_clipView == nil) {
        UIView *view = [[UIView alloc] init];
        _clipView = view;
        //设置clipView的背景色和透明度
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.5;
        //将clipView添加到tableView上，此时的clipView不会显示（未设置其frame）
        [_tableView addSubview:_clipView];
    }
    return _clipView;
}




//提示控件
- (void)popSecondAlertViewWithTitle:(NSString *)title Message:(NSString *)message{
    
    //弹出alert视图提示输入账号密码
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //        [self popSecondAlertViewWithTitle:nil Message:@"请手动选择当前位置"];
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"你点击了alert的确定按钮!");
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
