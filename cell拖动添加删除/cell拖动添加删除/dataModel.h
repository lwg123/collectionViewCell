//
//  dataModel.h
//  cell拖动添加删除
//
//  Created by weiguang on 2017/5/25.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface dataModel : NSObject

@property (nonatomic,strong) NSString *imageName;

@property (nonatomic,strong) NSString *appName;


+(instancetype)initWithDict:(NSDictionary *)dict;

@end
