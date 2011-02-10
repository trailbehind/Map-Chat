//
//  ProfileViewController.h
//  Chat
//
//  Created by EFB on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatController.h"

@interface ProfileViewController : UIViewController <UITextFieldDelegate, ChatControllerDelegate>{

	UITextField *nicknameField, *emailField;
	
}

@end
