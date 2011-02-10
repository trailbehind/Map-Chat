//
//  ProfileViewController.m
//  Chat
//
//  Created by EFB on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "ChatAppDelegate.h"


#define PADDING 10
#define LABEL_ROW_HEIGHT 20
#define TEXT_FIELD_ROW_HEIGHT 25
#define SECTION_HEIGHT 55


@implementation ProfileViewController

- (UITextField*) addTextFieldLabeled:(NSString*)labelText
															 atRow:(int)row 
										 withPlaceholder:(NSString*)placeholder {

	int rowOffset = PADDING + row * (SECTION_HEIGHT + PADDING);
	UILabel *label = [[[UILabel alloc]initWithFrame:CGRectMake(PADDING, 
																														 rowOffset,
																														 self.view.frame.size.width-PADDING*2,
																														 LABEL_ROW_HEIGHT)]autorelease];
	label.text = labelText;
	[self.view addSubview:label];
	UITextField *field = [[[UITextField alloc]initWithFrame:CGRectMake(PADDING, 
																																		 rowOffset + PADDING/2 + LABEL_ROW_HEIGHT,
																																		 self.view.frame.size.width-PADDING*2,
																																		 TEXT_FIELD_ROW_HEIGHT)]autorelease];
	field.placeholder = placeholder;
	field.borderStyle = UITextBorderStyleRoundedRect;
	field.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	field.returnKeyType = UIReturnKeyDone;
	field.delegate = self;
	[self.view addSubview:field];	
	return field;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
  [super loadView];	
	nicknameField = [[self addTextFieldLabeled:@"Enter the name to display in chat" 
																			 atRow:0 
														 withPlaceholder:@"Ex: jane_doe"]retain];

	emailField = [[self addTextFieldLabeled:@"Enter an email to get notified" 
																		atRow:1 
													withPlaceholder:@"Ex: jane@example.com"] retain];
	emailField.keyboardType = UIKeyboardTypeEmailAddress;
	
	ChatAppDelegate *appDelegate = (ChatAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.chatController.delegate = self;
}


#pragma mark -
#pragma mark UITextField delegate methods

// save the nickname or the email after the user presses done
- (void)textFieldDidEndEditing:(UITextField *)textField {
	ChatAppDelegate *appDelegate = (ChatAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([textField isEqual:nicknameField]) {
  	[appDelegate.chatController saveNickname:textField.text];
		return;
	}
	if ([textField isEqual:emailField]) {
  	[appDelegate.chatController saveEmail:textField.text];
		return;
	}
}


// hide the keyboard when the user presses Done
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;  
}


// callback after saving a nick name
- (void) didSaveName:(BOOL)didSucceed {
}


// callback after saving a email
- (void) didSaveEmail:(BOOL)didSucceed {
}


// make the view auto-rotatable
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	[super viewDidUnload];
	[nicknameField release]; nicknameField = nil;
	[emailField release]; emailField = nil;
	ChatAppDelegate *appDelegate = (ChatAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.chatController.delegate = nil;
}


- (void)dealloc {
	[super dealloc];
	
}


@end
