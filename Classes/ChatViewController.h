//
//  ChatViewController.h
//  Chat
//

#import <UIKit/UIKit.h>
#import "SocketIoClient.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"


@interface ChatViewController : UIViewController<SocketIoClientDelegate, UITextFieldDelegate> {	
	SocketIoClient *client;
	
    IBOutlet UITextField* textField;
    IBOutlet UITextView* textView;
    IBOutlet UIActivityIndicatorView* activityIndicator;
    
    IBOutlet UIButton* reconnectButton;
}

-(IBAction)reconnect:(id)sender;
@end
