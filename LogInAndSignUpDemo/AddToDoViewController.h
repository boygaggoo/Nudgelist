//
//  AddToDoViewController.h
//  LogInAndSignUpDemo
//
//  Created by HengHong on 6/4/13.
//
//

#import <UIKit/UIKit.h>

@interface AddToDoViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextField;

@end
