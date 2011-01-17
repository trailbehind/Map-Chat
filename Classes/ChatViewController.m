//
//  ChatViewController.m
//  Chat
//

#import "ChatViewController.h"
#import "ChatAppDelegate.h"
#import "ChatController.h"

#define TEXTFIELD_BG_HEIGHT 40

@implementation ChatViewController

- (void)dealloc {
  [super dealloc];
}


// write raw text to the textView
- (void)write:(NSString*)text {
  NSMutableString* newText = [NSMutableString stringWithString:textView.text];
  [newText appendString:text];
  [newText appendString:@"\n"];
  textView.text = newText;
  [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];
}


- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
  // only send if we're connected
  ChatAppDelegate *appDelegate = (ChatAppDelegate *)[[UIApplication sharedApplication] delegate];
	BOOL didSendMessage = [appDelegate.chatController sendMessage:textField.text];
	
  // clear out the input box
  [textField setText:@""];
  return didSendMessage;	
}


- (void)viewDidUnload {
	[textView release];
	[textFieldBackground release];
	[textField release];
}


-(void) keyboardWillShow:(NSNotification *) note {
	// get the frame and center of the keyboard so we can move the textField
	 CGRect keyboardFrame;
  [[note.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue: &keyboardFrame];
  CGPoint keyboardCenter; 
  [[note.userInfo valueForKey:UIKeyboardCenterEndUserInfoKey] getValue: &keyboardCenter];

  // make a copy of the textField background frame so we can modify it
  CGRect newTextFieldBGFrame  = textFieldBackground.frame;
	
	CGRect newTextViewFrame = textView.frame;
	
	// set the y-origin to above the keyboard
	int statusBarHeight = 20;
  newTextFieldBGFrame.origin.y =  
	  keyboardCenter.y 
   	 - keyboardFrame.size.height/2 
		 - TEXTFIELD_BG_HEIGHT 
	   - self.navigationController.navigationBar.frame.size.height 
	   - statusBarHeight;
	// assign the new frame back to the textFieldBackground's frame
  textFieldBackground.frame = newTextFieldBGFrame;
	
	// reduce the size of the textView to make room for the keyboard and textField
	newTextViewFrame.size.height =  
	  self.view.frame.size.height 
	- keyboardFrame.size.height 
	- TEXTFIELD_BG_HEIGHT;
	// assign the new frame back to the textView's frame
  textView.frame = newTextViewFrame;
	
	
}


- (void)viewDidLoad {
	// check with the chatController for a connection, or wait for the connection
	[super viewDidLoad];
	// create the textView that shows the chat
	textView = [[UITextView alloc]initWithFrame:self.view.frame];
	[self.view addSubview:textView];

	// create the gray background for the chat entry text field
  float textFieldYOrigin = self.view.frame.size.height
	                         - TEXTFIELD_BG_HEIGHT
													 - self.navigationController.navigationBar.frame.size.height;
	CGRect textFieldBGFrame = CGRectMake(0, 
																			 textFieldYOrigin,
																			 self.view.frame.size.width, 
																			 TEXTFIELD_BG_HEIGHT);
	textFieldBackground = [[UIView alloc]initWithFrame:textFieldBGFrame];
	textFieldBackground.backgroundColor = [UIColor grayColor];
	[self.view addSubview:textFieldBackground];
	
	// create the textField to enter chats and add it to the gray background
  int padding = 5;
	textField = [[UITextField alloc]initWithFrame:CGRectMake(padding, 
																													 padding, 
																													 textFieldBGFrame.size.width-padding*2, 
																													 textFieldBGFrame.size.height-padding*2)];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.delegate = self;
	[textFieldBackground addSubview:textField];
	
	// add a notification for when the keyboard shows, which moves up the text field
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self 
         selector:@selector(keyboardWillShow:) 
             name:UIKeyboardWillShowNotification 
           object:nil];
	// show the keyboard 
	[textField becomeFirstResponder];
  // remove the notification observer since the keyboard never shows or hides again
	[nc performSelector:@selector(removeObserver:) withObject:self afterDelay:1];
}



@end
