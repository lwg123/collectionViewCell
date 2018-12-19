//
//  ViewController.m
//  cell拖动添加删除
//
//  Created by weiguang on 2017/5/24.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import "ViewController.h"
#import "AppCollectionViewCell.h"


static NSString *identifier = @"AppsCell";

static CGFloat itemMargin = 15;
static CGFloat leftMargin = 5;

@interface ViewController ()
{
    BOOL isEditing;
    UIButton *rightButton;
    UIButton *leftButton;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong) NSMutableArray *viewModels;
@property (nonatomic,strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) NSIndexPath *originalIndexPath;
@property (nonatomic, weak) UIView *tempMoveCell;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, strong) NSIndexPath *moveIndexPath;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self getData];
}

// 获取数据源，此处为固定的
- (void)getData{
   
    _viewModels = [NSMutableArray array];
    
    NSArray *dataArr = @[@{@"imageName" : @"icaiwuyun", @"appName" : @"财务云"}, @{@"imageName" : @"icbaobiao", @"appName" : @"报表"}, @{@"imageName" : @"icchanghongyouxiang", @"appName" : @"邮箱"}, @{@"imageName" : @"icfuwucaigou", @"appName" : @"服务采购"}, @{@"imageName" : @"icgongwenchengbao", @"appName" : @"呈报"}, @{@"imageName" : @"icrenwu", @"appName" : @"任务"}, @{@"imageName" : @"icshenghuofuwu", @"appName" : @"生活服务"}, @{@"imageName" : @"icshenpi", @"appName" : @"审批"}, @{@"imageName" : @"icwenjian", @"appName" : @"文件"}, @{@"imageName" : @"iczixun", @"appName" : @"资讯"}];
    
    for (NSDictionary *dict in dataArr) {
        
        dataModel *model = [dataModel initWithDict:dict];
        [_viewModels addObject:model];
    }
}

// 设置UI界面
- (void)setupUI{
    
    isEditing = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    _collectionView.backgroundColor = RGB(238, 238, 244);
    _collectionView.alwaysBounceVertical = YES;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemH = ([UIScreen mainScreen].bounds.size.width - 3 * itemMargin - 2 * leftMargin) / 4;
    layout.itemSize = CGSizeMake(itemH, itemH);
    layout.minimumLineSpacing = itemMargin;
    layout.minimumInteritemSpacing = itemMargin;
    
    _collectionView.collectionViewLayout = layout;
    
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMoving:)];
    _longPress.minimumPressDuration = 1.0;
    [_collectionView addGestureRecognizer:_longPress];
    
    // 如果使用storyboard来加载cell就不要在注册了，否则会调用initWithFrame方法，重新加载一遍
    [_collectionView registerClass:[AppCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    
    // 在storyboard中已设置过dataSource和delegate
    //_collectionView.dataSource = self;
    _collectionView.contentInset = UIEdgeInsetsMake(leftMargin, leftMargin, 0, leftMargin);
   
    // 设置右边的item
    rightButton = [self setupBarButtonItem:@"完成"];
    [rightButton addTarget:self action:@selector(rightItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    rightButton.hidden = YES;
    
    // 设置左边添加按钮
    leftButton = [self setupBarButtonItem:@"添加"];
    [leftButton addTarget:self action:@selector(leftItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *lefItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = lefItem;
}


#pragma mark - 长按cell进入编辑状态，可以进行移动删除操作
- (void)longPressMoving:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            //获取当前手指长按的cell的indexPath
            _originalIndexPath = [_collectionView indexPathForItemAtPoint:[longPress locationInView:_collectionView]];
            if (_originalIndexPath.row > _viewModels.count) {
                return;
            }
            
            if (!isEditing) {
                [self enterEditingModel];
            }
            
            //获取到手指所在cell
            AppCollectionViewCell *cell = (AppCollectionViewCell *)[_collectionView cellForItemAtIndexPath:_originalIndexPath];
            
            //生成一个和cell一样的view
            UIView *cellView = [self viewFromCell:cell];
            // 生成cellView一样的image
            UIImage *cellImage = [self imageFromView:cellView];
            UIImageView *snapView = [[UIImageView alloc] initWithImage:cellImage];
            // 临时cell
            _tempMoveCell = snapView;
            _tempMoveCell.frame = cell.frame;
            
            // 当前的真实cell隐藏,表面上显示的临时的cell
            cell.hidden = YES;
            [_collectionView addSubview:_tempMoveCell];
            
            _lastPoint = [longPress locationOfTouch:0 inView:longPress.view];
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat tranX = [longPress locationOfTouch:0 inView:longPress.view].x - _lastPoint.x;
            CGFloat tranY = [longPress locationOfTouch:0 inView:longPress.view].y - _lastPoint.y;
            _tempMoveCell.center = CGPointApplyAffineTransform(_tempMoveCell.center, CGAffineTransformMakeTranslation(tranX, tranY));
            _lastPoint = [longPress locationOfTouch:0 inView:longPress.view];
            // 移动cell
            [self moveCell];

        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (_originalIndexPath.row > _viewModels.count) {
                return;
            }
            AppCollectionViewCell *cell = (AppCollectionViewCell *)[_collectionView cellForItemAtIndexPath:_originalIndexPath];
            _collectionView.userInteractionEnabled = NO;
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                _tempMoveCell.center = cell.center;
                _tempMoveCell.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                [_tempMoveCell removeFromSuperview];
                _originalIndexPath = nil;
                _tempMoveCell = nil;
                _collectionView.userInteractionEnabled = YES;
                
            }];

        }
            break;
        default:
            break;
    }
}

- (void)moveCell{
    for (AppCollectionViewCell *cell in [_collectionView visibleCells]) {
        NSIndexPath *index = [_collectionView indexPathForCell:cell];
        if (index == _originalIndexPath) {
            continue;
        }
        //计算中心距
        CGFloat spacingX = fabs(_tempMoveCell.center.x - cell.center.x);
        CGFloat spacingY = fabs(_tempMoveCell.center.y - cell.center.y);
        if (spacingX <= _tempMoveCell.bounds.size.width / 2.0f && spacingY <= _tempMoveCell.bounds.size.height / 2.0f) {
            _moveIndexPath = [_collectionView indexPathForCell:cell];
            if (_moveIndexPath.row<_viewModels.count) { //超出cell范围时移动会崩溃
                //更新数据源
                [self updateDataSource];
                //移动
                [_collectionView moveItemAtIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
                //设置移动后的起始indexPath
                _originalIndexPath = _moveIndexPath;
            }
            
            break;
        }
    }
    
}



//更新数据源
- (void)updateDataSource{
    NSMutableArray *temp = @[].mutableCopy;
    [temp addObjectsFromArray:_viewModels];
    if (_moveIndexPath.item > _originalIndexPath.item) {
        for (NSUInteger i = _originalIndexPath.item; i < _moveIndexPath.item ; i ++) {
            [temp exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
        }
    }else{
        for (NSUInteger i = _originalIndexPath.item; i > _moveIndexPath.item ; i --) {
            [temp exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
        }
    }
    _viewModels = temp.mutableCopy;
}


#pragma mark - App editing
// 进入编辑状态
- (void)enterEditingModel{
    isEditing = YES;
    rightButton.hidden = NO;
    _longPress.minimumPressDuration = 0.5;
    for (int i = 0; i < _viewModels.count; i++) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
        AppCollectionViewCell *cell = (AppCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexpath];
        cell.deleteBtn.hidden = NO;
    }
    
}

- (void)stopEditingModel {
    isEditing = NO;
    _longPress.minimumPressDuration = 1.0;
    rightButton.hidden = YES;
    for (int i = 0; i < _viewModels.count; i++) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
        AppCollectionViewCell *cell = (AppCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexpath];
        cell.deleteBtn.hidden = YES;
    }
}


#pragma mark - 生成左右button
- (UIButton *)setupBarButtonItem:(NSString *)title {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 50, 30);
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    
    return button;
}

#pragma mark - 生成一个和当前cell一样的view
- (UIView *)viewFromCell:(AppCollectionViewCell *)cell {
    
    UIView *view = [[UIView alloc] initWithFrame:cell.frame];
    view.backgroundColor = RGB(230, 230, 230);
    
    UIImageView *appImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width/3, cell.frame.size.width/3)];
    appImageView.image = cell.appImageView.image;
    appImageView.center = CGPointMake(cell.frame.size.width / 2.0, cell.frame.size.height / 2.0 - 10);
    [view addSubview:appImageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 20)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:12.0];
    nameLabel.text = cell.nameLabel.text;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = RGB(55, 55, 55);
    nameLabel.center = CGPointMake(cell.frame.size.width / 2.0, appImageView.frame.origin.y + appImageView.frame.size.height + nameLabel.frame.size.height / 2.0 + 3);
    [view addSubview:nameLabel];
    
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setImage:[UIImage imageNamed:@"shanchu"] forState:UIControlStateNormal];
    deleteBtn.frame = CGRectMake(cell.frame.size.width - 30, 0, 30, 30);
    deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    deleteBtn.hidden = NO;
    [view addSubview:deleteBtn];
    
    return view;
}

#pragma mark - 根据生成的临时View转成image
- (UIImage *)imageFromView:(UIView *)snapView {
    UIGraphicsBeginImageContext(snapView.frame.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [snapView.layer renderInContext:contextRef];
    UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return targetImage;
}


#pragma mark -  UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _viewModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AppCollectionViewCell *cell = (AppCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    dataModel *model = _viewModels[indexPath.item];
    [cell showInfoWithModel:model];
    
    [cell.deleteBtn addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if (isEditing) {
        cell.deleteBtn.hidden = NO;
    } else {
        cell.deleteBtn.hidden = YES;
    }
    
    return cell;
}

#pragma mark - 按钮点击事件监听
// 点击删除按钮，删除应用
- (void)deleteButtonPressed:(id)sender{
    AppCollectionViewCell *cell = (AppCollectionViewCell *)[sender superview].superview;
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    
    [_viewModels removeObjectAtIndex:indexPath.row];
    
    [_collectionView reloadData];
}

- (void)rightItemClick{
    if (isEditing) {
        [self stopEditingModel];
    }
}

// 点击添加按钮，随机添加数据
- (void)leftItemClick {
    int x = arc4random() % _viewModels.count;
    dataModel *model = _viewModels[x];
    
    [_viewModels addObject:model];
    [_collectionView reloadData];
}

@end
