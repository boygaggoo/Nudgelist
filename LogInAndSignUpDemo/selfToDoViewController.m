//
//  selfToDoViewController.m
//  LogInAndSignUpDemo
//
//  Created by HengHong on 7/4/13.
//
//

#import "selfToDoViewController.h"
#import "ToDoViewController.h"
@interface selfToDoViewController ()

@end

@implementation selfToDoViewController

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
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.doneTextField becomeFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self doneButton:nil];
    return NO;
}
- (IBAction)doneButton:(id)sender {
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:[NSString stringWithFormat:@"donechannel%@",self.pfobj.objectId]];
    [push setMessage:self.doneTextField.text];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //now set todo as done
            [self.pfobj setObject:[NSNumber numberWithBool:YES] forKey:@"completed"];
            [self.pfobj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [[ToDoViewController sharedInstance] completedPFobject:self.pfobj forUser:[PFUser currentUser]];
                [self.navigationController popViewControllerAnimated:YES];
            }];

                NSLog(@"pushed to %@",[NSString stringWithFormat:@"donechannel%@",self.pfobj.objectId]);
        }
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDoneTextField:nil];
    [super viewDidUnload];
}
@end
