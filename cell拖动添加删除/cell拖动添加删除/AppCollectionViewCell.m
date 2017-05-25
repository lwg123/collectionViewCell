//
//  AppCollectionViewCell.m
//  cell拖动添加删除
//
//  Created by weiguang on 2017/5/24.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import "AppCollectionViewCell.h"

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
@implementation AppCollectionViewCell



// 从storyboard中加载cell时才调用此方法
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.deleteBtn.hidden = YES;
    
}

// 通过注册cell的方式加载，调用此方法
- (instancetype)initWithFrame:(CGRect)frame {

   self =  [super initWithFrame:frame];
    
    if (self) {
        _appImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/3, self.frame.size.width/3)];
        
        _appImageView.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0 - 10);
        [self.contentView addSubview:_appImageView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:12.0];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = RGB(55, 55, 55);
        _nameLabel.center = CGPointMake(self.frame.size.width / 2.0, _appImageView.frame.origin.y + _appImageView.frame.size.height + _nameLabel.frame.size.height / 2.0 + 3);
        [self.contentView addSubview:_nameLabel];
        
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"shanchu"] forState:UIControlStateNormal];
        _deleteBtn.frame = CGRectMake(self.frame.size.width - 30, 0, 30, 30);
        _deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        _deleteBtn.hidden = YES;
        [self.contentView addSubview:_deleteBtn];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}


- (void)showInfoWithModel:(dataModel *)model {
    
    _nameLabel.text = model.appName;
    
    _appImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",model.imageName]];
}



@end
