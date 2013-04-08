//
//  ToDoViewController.h
//  LogInAndSignUpDemo
//
//  Created by HengHong on 6/4/13.
//
//

#import <UIKit/UIKit.h>

@interface ToDoViewController : UIViewController <PFLogInViewControllerDelegate,UITableViewDataSource ,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *todoTable;
@property (nonatomic,strong) NSMutableArray* ToDoArray;
@property (nonatomic,strong) NSMutableDictionary* mainTodoDictionary;
@property (nonatomic,strong) UIRefreshControl* refreshControl;
@property (nonatomic,strong) NSDate* DNDEndTime;
@property (nonatomic,strong) NSTimer* timer;
+ (ToDoViewController *)sharedInstance;
-(void)refreshing;
-(void)completedPFobject:(PFObject*)obj forUser:(PFUser*)user;
@end
