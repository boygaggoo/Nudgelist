//
//  elseToDoViewController.h
//  LogInAndSignUpDemo
//
//  Created by HengHong on 7/4/13.
//
//

#import <UIKit/UIKit.h>

@interface elseToDoViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *sendTextField;
@property (weak, nonatomic) PFObject* pfobj;
@end
