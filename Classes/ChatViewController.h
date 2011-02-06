//
//  ChatViewController.h
//  Chat
//

#import "ChatController.h"

@interface ChatViewController : UIViewController <UITextFieldDelegate, ChatControllerDelegate, UIWebViewDelegate> {	

	UITextField* textField;
	UIView *textFieldBackground;
	UIWebView *chatWebView;
	
}

@end
