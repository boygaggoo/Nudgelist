//
//  elseToDoViewController.m
//  LogInAndSignUpDemo
//
//  Created by HengHong on 7/4/13.
//
//

#import "elseToDoViewController.h"

@interface elseToDoViewController ()

@end

@implementation elseToDoViewController

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
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendButton:nil];
    return NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.sendTextField becomeFirstResponder];
}
- (IBAction)sendButton:(id)sender {
    [self.pfobj refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [[self.pfobj objectForKey:@"parent"] fetchIfNeededInBackgroundWithBlock:^(PFObject *fetched, NSError *error) {
        if (![[object objectForKey:@"completed"] boolValue]) {
            if ([[NSDate date] compare:[object objectForKey:@"next_send_date"]] == NSOrderedDescending && [[NSDate date] compare:[fetched objectForKey:@"user_next_send_date"]] == NSOrderedDescending) {
            {
                PFPush *push = [[PFPush alloc] init];
                [push setChannel:[NSString stringWithFormat:@"channel%@",[[self.pfobj objectForKey:@"parent"] objectId]]];
                [push setMessage:[NSString stringWithFormat:@"%@: %@",[self.pfobj objectForKey:@"title"],self.sendTextField.text]];
                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"pushed to %@",[NSString stringWithFormat:@"channel%@",[[self.pfobj objectForKey:@"parent"] objectId]]);
                        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Sent!" message:@"Reminder on the way!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        [object setObject:[NSDate dateWithTimeIntervalSinceNow:60] forKey:@"next_send_date"];
                        [object incrementKey:@"nudge_count"];
                        [object saveInBackground];
                        }
                }];
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:[NSString stringWithFormat:@"donechannel%@",self.pfobj.objectId] forKey:@"channels"];
                [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"saved channel");
                }];
                }
            }else{
                NSDate* nextsend = [object objectForKey:@"next_send_date"];
                NSDate* usernextsend = [fetched objectForKey:@"user_next_send_date"];
                    if ([usernextsend compare:nextsend] == NSOrderedDescending ) {
                        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"DND Mode On!" message:[NSString stringWithFormat:@"next send in %.0f seconds",[usernextsend timeIntervalSinceDate:[NSDate date]]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];                    
                    }else{
                        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Cant send message" message:[NSString stringWithFormat:@"next send in %.0f seconds",[nextsend timeIntervalSinceDate:[NSDate date]]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                }
            
        }
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSendTextField:nil];
    [super viewDidUnload];
}
@end
