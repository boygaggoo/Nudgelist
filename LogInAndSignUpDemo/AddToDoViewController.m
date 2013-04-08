//
//  AddToDoViewController.m
//  LogInAndSignUpDemo
//
//  Created by HengHong on 6/4/13.
//
//

#import "AddToDoViewController.h"
#import "ToDoViewController.h"
@interface AddToDoViewController ()

@end

@implementation AddToDoViewController

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
//    UIBarButtonItem* bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addToDo)];
//    self.navigationItem.rightBarButtonItem = bbi;
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.titleTextField becomeFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addToDo
{
    PFObject *newToDo = [PFObject objectWithClassName:@"ToDo"];
    [newToDo setObject:self.titleTextField.text forKey:@"title"];
    [newToDo setObject:self.contentTextField.text forKey:@"content"];
    [newToDo setObject:[NSNumber numberWithBool:NO] forKey:@"completed"];
    [newToDo setObject:[NSDate date] forKey:@"next_send_date"];
    [newToDo setObject:[NSNumber numberWithInt:0] forKey:@"nudge_count"];

    // Create the comment
    
    // Add a relation between the Post and Comment
    [newToDo setObject:[PFUser currentUser] forKey:@"parent"];
    
    // This will save both myPost and myComment
    [newToDo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            int currentIndex = [self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
            [((NSMutableArray*)[((ToDoViewController*)[self.navigationController.viewControllers objectAtIndex:(currentIndex-1)]).mainTodoDictionary objectForKey:[[PFUser currentUser] objectForKey:@"name"]]) addObject:newToDo];
            //create a new channel and be in it
            [((ToDoViewController*)[self.navigationController.viewControllers objectAtIndex:(currentIndex-1)]).todoTable reloadData];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self performSelector:@selector(addToDo)];
    return YES;
}

- (void)viewDidUnload {
    [self setTitleTextField:nil];
    [self setContentTextField:nil];
    [super viewDidUnload];
}
@end
