//
//  ChatViewController.h
//  Chat
//

#import "ChatController.h"

@interface ChatViewController : UIViewController <UITextFieldDelegate, ChatControllerDelegate> {	

	UITextField* textField;
	UIView *textFieldBackground;
	UITextView* textView;
	
}

@end
