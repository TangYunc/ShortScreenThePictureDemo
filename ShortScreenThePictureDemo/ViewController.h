//
//  ViewController.h
//  ShortScreenThePictureDemo
//
//  Created by 唐云川 on 2017/4/25.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource>
{
    NSArray *_dateList;   // 所有字体的名字
    UITableView *_tableView;   // 表视图
}


@end

