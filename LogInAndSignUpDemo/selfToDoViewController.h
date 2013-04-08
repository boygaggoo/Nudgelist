//
//  selfToDoViewController.h
//  LogInAndSignUpDemo
//
//  Created by HengHong on 7/4/13.
//
//

#import <UIKit/UIKit.h>

@interface selfToDoViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *doneTextField;
@property (weak, nonatomic) PFObject* pfobj;

@end
