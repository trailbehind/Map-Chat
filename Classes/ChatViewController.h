//
//  ChatViewController.h
//  Chat
//
//  Created by Esad Hajdarevic on 2/16/10.
//  Copyright OpenResearch Software Development OG 2010. All rights reserved.
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