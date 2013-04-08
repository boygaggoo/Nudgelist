//
//  ToDoViewController.m
//  LogInAndSignUpDemo
//
//  Created by HengHong on 6/4/13.
//
//
#import "elseToDoViewController.h"
#import "selfToDoViewController.h"
#import "ToDoViewController.h"
#import "ToDoDetailViewController.h"
#import "AddToDoViewController.h"
#import <Parse/Parse.h>
#import "AFHTTPClient.h"

@interface ToDoViewController ()

@end

@implementation ToDoViewController



// Get the shared instance and create it if necessary.
+ (ToDoViewController *)sharedInstance {
        
        static ToDoViewController *sharedInstance = nil;
        static dispatch_once_t pred;
        
        dispatch_once(&pred, ^{
            sharedInstance = [[ToDoViewController alloc]initWithNibName:@"ToDoViewController" bundle:nil];
        });
        
        return sharedInstance;
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.mainTodoDictionary = [[NSMutableDictionary alloc]init];
    self.ToDoArray = [[NSMutableArray alloc]init];
    self.refreshControl  = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshing) forControlEvents:UIControlEventValueChanged];
    
    [self.todoTable addSubview:self.refreshControl];
    self.todoTable.delegate = self;
    self.todoTable.dataSource = self;
    if ([PFUser currentUser]) {
        self.DNDEndTime = [[PFUser currentUser] objectForKey:@"user_next_send_date"];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTime) userInfo:nil repeats:YES];
        PFQuery* query = [PFQuery queryWithClassName:@"ToDo"];
        [query whereKey:@"parent" equalTo:[PFUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSMutableArray* objectArray = [[NSMutableArray alloc]initWithArray:objects];
            [self.mainTodoDictionary setObject:objectArray forKey:[[PFUser currentUser] objectForKey:@"name"]];
            PF_FBRequest *friendsRequest = [PF_FBRequest requestForMyFriends];
            [friendsRequest startWithCompletionHandler:^(PF_FBRequestConnection *connection,
                                                         id result,
                                                         NSError *error) {
                if (!error) {
                    // result will contain an array with your user's friends in the "data" key
                    NSArray *friendObjects = [result objectForKey:@"data"];
                    NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
                    // Create a list of friends' Facebook IDs
                    for (NSDictionary *friendObject in friendObjects) {
                        [friendIds addObject:[friendObject objectForKey:@"id"]];
                    }
                    
                    // Construct a PFUser query that will find friends whose facebook ids
                    // are contained in the current user's friend list.
                    PFQuery *friendQuery = [PFUser query];
                    [friendQuery whereKey:@"fbId" containedIn:friendIds];
                    
                    // findObjects will return a list of PFUsers that are friends
                    // with the current user
                    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (objects.count>0) {
                            NSLog(@"objects = %@",objects);
                            for (PFUser* friend in objects) {
                                NSLog(@"found friend");
                                PFQuery* query = [PFQuery queryWithClassName:@"ToDo"];
                                [query whereKey:@"parent" equalTo:friend];
                                [query findObjectsInBackgroundWithBlock:^(NSArray *objectsasd, NSError *error) {
                                    NSLog(@"settting %@ for %@",objectsasd,[friend objectForKey:@"name"]);
                                    [self.mainTodoDictionary setObject:objectsasd forKey:[friend objectForKey:@"name"]];
                                    [self.todoTable reloadData];
                                }];
                                
                            }
                            
                        }
                        
                    }];
                    
                    
                }
            }];
        }];
        
        

    }

    UIBarButtonItem* signout = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStyleBordered target:self action:@selector(signOut)];
    self.navigationItem.leftBarButtonItem = signout;
    
    UIBarButtonItem* bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTodo)];
    self.navigationItem.rightBarButtonItem = bbi;
    [self.view addSubview:self.todoTable];

    // Do any additional setup after loading the view from its nib.
}
-(void)countTime
{
    if ([self.DNDEndTime timeIntervalSinceDate:[NSDate date]] > 0){
        self.navigationItem.title = [NSString stringWithFormat:@"%.0fs of DND left",[self.DNDEndTime timeIntervalSinceDate:[NSDate date]]];
    }else{
        self.navigationItem.title = [NSString stringWithFormat:@"Nudgelist"];
    }
}

-(void)refreshing
{
    if ([PFUser currentUser]) {

        PFQuery* query = [PFQuery queryWithClassName:@"ToDo"];
        [query whereKey:@"parent" equalTo:[PFUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSMutableArray* objectArray = [[NSMutableArray alloc]initWithArray:objects];
            [self.mainTodoDictionary setObject:objectArray forKey:[[PFUser currentUser] objectForKey:@"name"]];
            
        }];
        
        
        PF_FBRequest *friendsRequest = [PF_FBRequest requestForMyFriends];
        [friendsRequest startWithCompletionHandler:^(PF_FBRequestConnection *connection,
                                                     id result,
                                                     NSError *error) {
            if (!error) {
                // result will contain an array with your user's friends in the "data" key
                NSArray *friendObjects = [result objectForKey:@"data"];
                NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
                // Create a list of friends' Facebook IDs
                for (NSDictionary *friendObject in friendObjects) {
                    [friendIds addObject:[friendObject objectForKey:@"id"]];
                }
                
                // Construct a PFUser query that will find friends whose facebook ids
                // are contained in the current user's friend list.
                PFQuery *friendQuery = [PFUser query];
                [friendQuery whereKey:@"fbId" containedIn:friendIds];
                
                // findObjects will return a list of PFUsers that are friends
                // with the current user
                [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (objects.count>0) {
                        NSLog(@"objects = %@",objects);
                        for (PFUser* friend in objects) {
                            NSLog(@"found friend");
                            PFQuery* query = [PFQuery queryWithClassName:@"ToDo"];
                            [query whereKey:@"parent" equalTo:friend];
                            [query findObjectsInBackgroundWithBlock:^(NSArray *objectsasd, NSError *error) {
                                NSLog(@"settting %@ for %@",objectsasd,[friend objectForKey:@"name"]);
                                [self.mainTodoDictionary setObject:objectsasd forKey:[friend objectForKey:@"name"]];
                                [self.todoTable reloadData];
                            }];
                        }
                    }
                    [self.refreshControl endRefreshing];
                }];
                
                
            }
        }];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if ([[[self.mainTodoDictionary allKeys] objectAtIndex:indexPath.section] isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]) {
        return YES;
    }else{
        return NO;
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
      PFObject* obj = [((NSMutableArray*)[self.mainTodoDictionary objectForKey:[[self.mainTodoDictionary allKeys] objectAtIndex:indexPath.section]]) objectAtIndex:indexPath.row];
      [obj refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
          [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
              [self refreshing];
          }];
      }];
       
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return number of friends
    return [self.mainTodoDictionary allKeys].count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSLog(@"self.main = %@",[self.mainTodoDictionary allKeys]);
    return ((NSMutableArray*)[self.mainTodoDictionary objectForKey:[[self.mainTodoDictionary allKeys] objectAtIndex:section]]).count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"mycell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    PFObject* obj = [((NSMutableArray*)[self.mainTodoDictionary objectForKey:[[self.mainTodoDictionary allKeys] objectAtIndex:indexPath.section]]) objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:25.0f]];
    
    cell.textLabel.text = [obj objectForKey:@"title"];
    if ([[obj objectForKey:@"completed"] boolValue]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    cell.detailTextLabel.text = [obj objectForKey:@"content"];

//    cell.textLabel.text = @"test";
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject* obj = [((NSMutableArray*)[self.mainTodoDictionary objectForKey:[[self.mainTodoDictionary allKeys] objectAtIndex:indexPath.section]]) objectAtIndex:indexPath.row];
    switch ([[obj objectForKey:@"nudge_count"]intValue]) {
        case 0:
            [cell.textLabel setBackgroundColor:[UIColor whiteColor]];
            [cell.contentView.superview setBackgroundColor:[UIColor whiteColor]];
            [cell.backgroundView setBackgroundColor:[UIColor whiteColor]];
            [cell.contentView setBackgroundColor:[UIColor whiteColor]];
            break;
        case 1:
            [cell.textLabel setBackgroundColor:[UIColor yellowColor]];
            [cell.backgroundView setBackgroundColor:[UIColor yellowColor]];
            [cell.contentView.superview setBackgroundColor:[UIColor yellowColor]];
            [cell.contentView setBackgroundColor:[UIColor yellowColor]];
            break;
        case 2:
            [cell.textLabel setBackgroundColor:[UIColor orangeColor]];
            [cell.backgroundView setBackgroundColor:[UIColor orangeColor]];
            [cell.contentView.superview setBackgroundColor:[UIColor orangeColor]];
            [cell.contentView setBackgroundColor:[UIColor orangeColor]];
            break;
        case 3:
            [cell.textLabel setBackgroundColor:[UIColor redColor]];
            [cell.backgroundView setBackgroundColor:[UIColor redColor]];
            [cell.contentView.superview setBackgroundColor:[UIColor redColor]];
            [cell.contentView setBackgroundColor:[UIColor redColor]];
            break;
        default:
            [cell.textLabel setBackgroundColor:[UIColor redColor]];
            [cell.backgroundView setBackgroundColor:[UIColor redColor]];
            [cell.contentView.superview setBackgroundColor:[UIColor redColor]];
            [cell.contentView setBackgroundColor:[UIColor redColor]];
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,60 )];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    PFQuery* userquery = [PFUser query];
    [userquery whereKey:@"name" equalTo:[[self.mainTodoDictionary allKeys] objectAtIndex:section]];
    [userquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PF_FBProfilePictureView* profile = [[PF_FBProfilePictureView alloc]initWithProfileID:[[objects lastObject] objectForKey:@"fbId"] pictureCropping:PF_FBProfilePictureCroppingSquare];
        [profile setFrame:CGRectMake(5, 5, 50, 50)];
        [headerView addSubview:profile];        
    }];
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, self.view.bounds.size.width-60, 60)];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setFont:[UIFont boldSystemFontOfSize:25.0f]];
    [label setText:[[self.mainTodoDictionary allKeys] objectAtIndex:section]];
    [label setBackgroundColor:[UIColor clearColor]];
    [headerView  addSubview:label];
    UIButton* nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nameButton setBackgroundColor:[UIColor clearColor]];
    [nameButton setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [nameButton addTarget:self action:@selector(kajiao:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:nameButton];
    return headerView;
}
-(void)kajiao:(UIButton*)sender
{
    UIView* header = sender.superview;
    for (UIView* view in header.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"name" equalTo:((UILabel*)view).text];
            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects.count>0 && ![[[objects lastObject]objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                    PFQuery* query = [PFQuery queryWithClassName:@"ToDo"];
                    [query whereKey:@"parent" equalTo:[objects lastObject]];
                    [query whereKey:@"completed" equalTo:[NSNumber numberWithBool:NO]];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *fetchedobjects, NSError *error) {
                        NSLog(@"fetched obj = %@",fetchedobjects);
                        if(fetchedobjects.count==0){
                            if ([[NSDate date] compare:[[[objects lastObject] fetchIfNeeded] objectForKey:@"user_next_send_date"]] == NSOrderedDescending ) {
                                PFPush *push = [[PFPush alloc] init];
                                [push setChannel:[NSString stringWithFormat:@"channel%@",[[objects lastObject] objectId]]];
                                [push setMessage:@"dun lazy..add some to do lehhh!"];
                                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Poke Sent!" message:@"Ouch!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                    [alert show];
                                }];
                            }else{
                                NSDate* targetdndend = [[[objects lastObject] fetchIfNeeded] objectForKey:@"user_next_send_date"];
                                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"DND!" message:[NSString stringWithFormat:@"Target User is in DND mode, %.0f seconds left! Come back later!",[targetdndend timeIntervalSinceDate:[NSDate date]]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [alert show];
                            }
                        }else{
                            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Cant Send!" message:@"User has ongoing todos, Make them do those first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }
                        
                    }];
                }
            }];
            
        }
    }
}
-(void)addTodo
{
    AddToDoViewController* viewController = [[AddToDoViewController alloc]initWithNibName:@"AddToDoViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    
   
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject* obj = [((NSMutableArray*)[self.mainTodoDictionary objectForKey:[[self.mainTodoDictionary allKeys] objectAtIndex:indexPath.section]]) objectAtIndex:indexPath.row];
    [obj refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if ([[object objectForKey:@"completed"]boolValue]) {
            if ([[[object objectForKey:@"parent"]objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Task Completed" message:@"No one can disturb you now" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }else{
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Task Completed" message:@"Dang, no reason to nudge them anymore" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
        }else{
            if ([[[object objectForKey:@"parent"] objectId] isEqualToString:[[PFUser currentUser] objectId]]){
                selfToDoViewController* selfTodo = [[selfToDoViewController alloc]initWithNibName:@"selfToDoViewController" bundle:nil];
                selfTodo.pfobj = obj;            
                [self.navigationController pushViewController:selfTodo animated:YES];
            }else{
                elseToDoViewController* elsetodo = [[elseToDoViewController alloc]initWithNibName:@"elseToDoViewController" bundle:nil];
                elsetodo.pfobj = obj;
                [self.navigationController pushViewController:elsetodo animated:YES];
                
            }
        }
    }];
    
    
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
        // Check if user is logged in
        if (![PFUser currentUser]) {

            // Customize the Log In View Controller
            PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
            [logInViewController setDelegate:self];
            [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
            [logInViewController setFields: PFLogInFieldsFacebook ];
            
            // Present Log In View Controller
            [self presentViewController:logInViewController animated:YES completion:NULL];
        }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)completedPFobject:(PFObject*)obj forUser:(PFUser*)user
{
    
    for (PFObject* object in [self.mainTodoDictionary objectForKey:[user objectForKey:@"name"]]) {
        if ([object.objectId isEqualToString:obj.objectId]) {
            [object refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if ([[NSDate date] compare:[NSDate dateWithTimeInterval:1200 sinceDate:[[PFUser currentUser] objectForKey:@"user_next_send_date"]]] == NSOrderedDescending) {
                    [[PFUser currentUser]setObject:[NSDate dateWithTimeInterval:1200 sinceDate:[NSDate date]] forKey:@"user_next_send_date"];
                }else{
                    [[PFUser currentUser]setObject:[NSDate dateWithTimeInterval:1200 sinceDate:[[PFUser currentUser] objectForKey:@"user_next_send_date"]] forKey:@"user_next_send_date"];
                }
                self.DNDEndTime = [[PFUser currentUser] objectForKey:@"user_next_send_date"];
                [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Hurray!" message:@"You have earned 20 min of DND time!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }];
                [self.todoTable reloadData];
            }];
        }
    }

}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {

    if (user) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:[NSString stringWithFormat:@"channel%@",[[PFUser currentUser] objectId]] forKey:@"channels"];
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"saved user channel");
        }];
        PF_FBRequest *request = [PF_FBRequest requestForMe];
        [request startWithCompletionHandler:^(PF_FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            if (!error) {
                // Store the current user's Facebook ID on the user
                NSLog(@"result = %@",result);
                [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                         forKey:@"fbId"];
                [[PFUser currentUser] setObject:[result objectForKey:@"first_name"]
                                         forKey:@"first_name"];
                [[PFUser currentUser] setObject:[result objectForKey:@"email"]
                                         forKey:@"email"];
                [[PFUser currentUser] setObject:[result objectForKey:@"name"]
                                         forKey:@"name"];
                [[PFUser currentUser] setObject:[NSDate date]
                                         forKey:@"user_next_send_date"];
                [[PFUser currentUser] saveInBackground];
            }
        }];
        PFQuery* query = [PFQuery queryWithClassName:@"ToDo"];
        [query whereKey:@"parent" equalTo:[PFUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"found %d objects ", objects.count);
            [self.ToDoArray removeAllObjects];
            [self.ToDoArray addObjectsFromArray:objects];
            [self.todoTable reloadData];
        }];
        
        
        PF_FBRequest *friendsRequest = [PF_FBRequest requestForMyFriends];
        [friendsRequest startWithCompletionHandler:^(PF_FBRequestConnection *connection,
                                                     id result,
                                                     NSError *error) {
            if (!error) {
                // result will contain an array with your user's friends in the "data" key
                NSArray *friendObjects = [result objectForKey:@"data"];
                NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
                // Create a list of friends' Facebook IDs
                for (NSDictionary *friendObject in friendObjects) {
                    [friendIds addObject:[friendObject objectForKey:@"id"]];
                }
                
                // Construct a PFUser query that will find friends whose facebook ids
                // are contained in the current user's friend list.
                PFQuery *friendQuery = [PFUser query];
                [friendQuery whereKey:@"fbId" containedIn:friendIds];
                
                // findObjects will return a list of PFUsers that are friends
                // with the current user
                NSArray *friendUsers = [friendQuery findObjects];
                if (friendUsers.count>0) {
                    for (PFUser* friend in friendUsers) {
                        NSLog(@"found friend");
                        PFQuery* query = [PFQuery queryWithClassName:@"ToDo"];
                        [query whereKey:@"parent" equalTo:friend];
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            [self.ToDoArray removeAllObjects];
                            [self.ToDoArray addObjectsFromArray:objects];
                        }];
                    }
                }
            }
        }];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...%@",error);
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setTodoTable:nil];
    [super viewDidUnload];
}
-(void)signOut
{
       [PFUser logOut];
    [self viewDidAppear:nil];
}
@end
