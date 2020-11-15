//
//  EaseConversationsViewController.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import "EaseConversationsViewController.h"
#import "EaseHeaders.h"
#import "EaseConversationViewModel.h"
#import "EaseConversationCell.h"

#import "EaseConversationItemDelegate.h"
#import "EaseConversationItem.h"

@interface EaseConversationsViewController ()
<
    EMContactManagerDelegate,
    EMChatManagerDelegate,
    EMGroupManagerDelegate
>
{
    dispatch_queue_t _loadDataQueue;
}
@property (nonatomic, strong) UIView *blankPerchView;

@end

@implementation EaseConversationsViewController
@synthesize viewModel = _viewModel;
@synthesize easeTableViewDelegate = _easeTableViewDelegate;

- (instancetype)initWithModel:(EaseBaseTableViewModel *)aModel{
    if (self = [super initWithModel:aModel]) {
        _loadDataQueue = dispatch_queue_create("com.easemob.easeui.conversations.queue", 0);
        [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
        [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
        [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)resetViewModel:(EaseConversationViewModel *)viewModel{
    [super resetViewModel:viewModel];
}


- (void)dealloc
{
    NSLog(@"conversaitons vc dealloc");
}

//空白占位视图
- (void)updateBlankPerchView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.dataAry count] == 0) {
            self.blankPerchView.hidden = NO;
        } else if ([self.dataAry count] > 0) {
            self.blankPerchView.hidden = YES;
        }
    });
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.easeTableViewDelegate && [self.easeTableViewDelegate respondsToSelector:@selector(easeTableView:heightForItem:)]) {
        return [self.easeTableViewDelegate easeTableView:tableView heightForItem:self.dataAry[indexPath.row]];
    }
    
    return self.viewModel.cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataAry count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EaseConversationCell *cell = (EaseConversationCell *)[tableView dequeueReusableCellWithIdentifier:@"EaseConversationCell"];
    if (!cell) {
        cell = [[EaseConversationCell alloc] initWithConversationViewModel:(EaseConversationViewModel *)_viewModel];
    }
    
    id<EaseConversationItemDelegate> model = [self.dataAry objectAtIndex:indexPath.row];
    cell.model = model;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    id<EaseConversationItemDelegate> model = [self.dataAry objectAtIndex:row];
    if (self.easeTableViewDelegate && [self.easeTableViewDelegate respondsToSelector:@selector(easeTableView:didSelectItem:)]) {
        [self.easeTableViewDelegate easeTableView:tableView didSelectItem:model];
        return;
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos)
{
    id<EaseConversationItemDelegate> model = [self.dataAry objectAtIndex:indexPath.row];
    
    if (self.easeTableViewDelegate && [self.easeTableViewDelegate respondsToSelector:@selector(tableView:trailingSwipeActionsConfigurationForRowAtItem:)]) {
        return [self.easeTableViewDelegate tableView:tableView trailingSwipeActionsConfigurationForRowAtItem:model];
    }
    
    __weak typeof(self) weakself = self;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [tableView setEditing:NO animated:YES];
        [weakself _deleteConversation:indexPath];
    }];
    deleteAction.backgroundColor = [UIColor colorWithRed: 253 / 255.0 green: 81 / 255.0 blue: 84 / 255.0 alpha:1.0];
    
    UIContextualAction *stickConversationAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"置顶" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [tableView setEditing:NO animated:YES];
//        [weakself _stickConversation:indexPath];
    }];
    stickConversationAction.backgroundColor = [UIColor colorWithRed: 203 / 255.0 green: 125 / 255.0 blue: 50 / 255.0 alpha:1.0];
    
    UIContextualAction *cancelStickConversationAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"取消置顶" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [tableView setEditing:NO animated:YES];
//        [weakself _cancelStickConversation:indexPath];
    }];
    cancelStickConversationAction.backgroundColor = [UIColor colorWithRed: 203 / 255.0 green: 125 / 255.0 blue: 50 / 255.0 alpha:1.0];
    
    UIContextualAction *customContextualAction = nil;
//    if (self.easeTableViewDelegate && [self.easeTableViewDelegate respondsToSelector:@selector(sideslipCustomAction:dataArray:trailingSwipeActionsConfigurationForRowAtIndexPath:)]) {
//        customContextualAction = [self.easeTableViewDelegate sideslipCustomAction:tableView dataArray:self.dataAry trailingSwipeActionsConfigurationForRowAtIndexPath:indexPath];
//    }
    
    NSMutableArray<UIContextualAction *> *sideslipArray = [[NSMutableArray alloc]init];
    [sideslipArray addObject:deleteAction];
//    if(model.isStick) {
//        [sideslipArray addObject:cancelStickConversationAction];
//    } else {
//        [sideslipArray addObject:stickConversationAction];
//    }
//    if (customContextualAction) {
//        [sideslipArray addObject:customContextualAction];
//    }
    
    UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:sideslipArray];
    actions.performsFirstActionWithFullSwipe = YES;
    return actions;
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidRecall:(NSArray *)aMessages {
    [self _loadAllConversationsFromDB];
}

- (void)messagesDidReceive:(NSArray *)aMessages
{
    [self _loadAllConversationsFromDB];
}

#pragma mark - EMGroupManagerDelegate

- (void)didLeaveGroup:(EMGroup *)aGroup
               reason:(EMGroupLeaveReason)aReason
{
    // 这个逻辑不对，删除会话和被移除群组是两个事儿。
//    [[EMClient sharedClient].chatManager deleteConversation:aGroup.groupId isDeleteMessages:NO completion:nil];
}


#pragma mark - EMConversationsDelegate

- (void)didConversationUnreadCountToZero:(id<EaseConversationItemDelegate>)aConversation
{
    NSInteger index = [self.dataAry indexOfObject:aConversation];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

#pragma mark - UIMenuController

//删除会话
- (void)_deleteConversation:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    id<EaseConversationItemDelegate> model = [self.dataAry objectAtIndex:row];
    [[EMClient sharedClient].chatManager deleteConversation:model.itemId
                                           isDeleteMessages:YES
                                                 completion:nil];
    [self.dataAry removeObjectAtIndex:row];
    [self.tableView reloadData];
    [self updateBlankPerchView];
}


- (void)_loadAllConversationsFromDB
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_loadDataQueue, ^{
        NSArray *conversations = [EMClient.sharedClient.chatManager getAllConversations];
        
        NSMutableArray<EaseConversationItemDelegate> *convs = [NSMutableArray<EaseConversationItemDelegate> array];
        NSMutableArray<EaseConversationItemDelegate> *topConvs = [NSMutableArray<EaseConversationItemDelegate> array];
        
        for (EMConversation *conv in conversations) {
            EaseConversationItem *item = [[EaseConversationItem alloc] initWithConversation:conv];
            if (item.isTop) {
                [topConvs addObject:item];
            }else {
                [convs addObject:item];
            }
        }
        
        NSArray *normalConvList = [convs sortedArrayUsingComparator:
                                   ^NSComparisonResult(id  <EaseConversationItemDelegate> obj1, id  <EaseConversationItemDelegate> obj2)
        {
            if (obj1.lastestUpdateTime > obj2.lastestUpdateTime) {
                return(NSComparisonResult)NSOrderedAscending;
            }else {
                return(NSComparisonResult)NSOrderedDescending;
            }
        }];
        
        NSArray *topConvList = [topConvs sortedArrayUsingComparator:
                                ^NSComparisonResult(id  <EaseConversationItemDelegate> obj1, id  <EaseConversationItemDelegate> obj2)
        {
            if (obj1.lastestUpdateTime > obj2.lastestUpdateTime) {
                return(NSComparisonResult)NSOrderedAscending;
            }else {
                return(NSComparisonResult)NSOrderedDescending;
            }
        }];
        
        NSMutableArray *totals = [NSMutableArray array];
        [totals addObjectsFromArray:topConvList];
        [totals addObjectsFromArray:normalConvList];
        
        weakSelf.dataAry = (NSMutableArray<EaseConversationItemDelegate> *)totals;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf endRefresh];
            [weakSelf updateBlankPerchView];
        });
    });
}

- (void)refreshTabView
{
    [self _loadAllConversationsFromDB];
}


@end
