//
//  AppCollectionViewCell.h
//  cell拖动添加删除
//
//  Created by weiguang on 2017/5/24.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dataModel.h"

@interface AppCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UIButton *deleteBtn;
@property (nonatomic,strong) UIImageView *appImageView;
@property (nonatomic,strong) UILabel *nameLabel;

- (void)showInfoWithModel:(dataModel *)model;

@end
