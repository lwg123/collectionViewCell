//
//  dataModel.m
//  cell拖动添加删除
//
//  Created by weiguang on 2017/5/25.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import "dataModel.h"

@implementation dataModel

- (instancetype)initWith:(NSDictionary *)dict {
    
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

+(instancetype)initWithDict:(NSDictionary *)dict{

    return [[self alloc] initWith:dict];
}

@end
