//
//  ConversationsViewController.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/5.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ConversationsViewController.h"
#import <EaseIMKit.h>
#import "EaseChatViewController.h"
#import "DemoUserModel.h"

@interface ConversationsViewController () <EaseConversationsViewControllerDelegate>
{
    EaseConversationsViewController *_easeConvsVC;
}
@end

@implementation ConversationsViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if ([view isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
            [view.subviews firstObject].hidden = YES;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    
    EaseConversationViewModel *viewMdeol = [[EaseConversationViewModel alloc] init];
    viewMdeol.canRefresh = NO;
    viewMdeol.avatarType = Circular;
    viewMdeol.badgeLabelPosition = EMAvatarTopRight;
    
    _easeConvsVC = [[EaseConversationsViewController alloc] initWithModel:viewMdeol];
    _easeConvsVC.delegate = self;
    [self addChildViewController:_easeConvsVC];
    [self.view addSubview:_easeConvsVC.view];
    [_easeConvsVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self updateConversationViewTableHeader];
}
   
#pragma mark - EaseConversationsViewControllerDelegate

- (void)easeTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EaseChatViewController *chatController = [[EaseChatViewController alloc]init];
    EaseConversationModel *model = _easeConvsVC.dataAry[indexPath.row];
    
    chatController.chatter = model.easeId;
    chatController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatController animated:YES];
}


- (id<EaseUserDelegate>)easeUserDelegateAtConversationId:(NSString *)conversationId
                                        conversationType:(EMConversationType)type
{
    
    DemoUserModel *model = [[DemoUserModel alloc] initWithEaseId:conversationId];
//    model.nickName =  @"我是昵称";
    return model;
}


- (void)updateConversationViewTableHeader {
    _easeConvsVC.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    _easeConvsVC.tableView.tableHeaderView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectZero];
    control.clipsToBounds = YES;
    control.layer.cornerRadius = 18;
    control.backgroundColor = UIColor.whiteColor;
    
    [_easeConvsVC.tableView.tableHeaderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_easeConvsVC.tableView);
        make.width.equalTo(_easeConvsVC.tableView);
        make.top.equalTo(_easeConvsVC.tableView);
        make.height.mas_equalTo(52);
    }];
    
    [_easeConvsVC.tableView.tableHeaderView addSubview:control];
    [control mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(36);
        make.top.equalTo(_easeConvsVC.tableView.tableHeaderView).offset(8);
        make.bottom.equalTo(_easeConvsVC.tableView.tableHeaderView).offset(-8);
        make.left.equalTo(_easeConvsVC.tableView.tableHeaderView.mas_left).offset(17);
        make.right.equalTo(_easeConvsVC.tableView.tableHeaderView).offset(-16);
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:16];
    label.text = @"搜索";
    label.textColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1];
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    UIView *subView = [[UIView alloc] init];
    [subView addSubview:imageView];
    [subView addSubview:label];
    [control addSubview:subView];
    
    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(15);
        make.left.equalTo(subView);
        make.top.equalTo(subView);
        make.bottom.equalTo(subView);
    }];
    
    [label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(3);
        make.right.equalTo(subView);
        make.top.equalTo(subView);
        make.bottom.equalTo(subView);
    }];
    
    [subView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(control);
    }];
}

@end
