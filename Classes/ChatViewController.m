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


- (id) init {
  self = [super init];
	return self;	
}


// write raw text to the textView
- (void)write:(NSString*)text user:(NSString*)user {
  NSString *htmlString;
  if (!user) {
    htmlString = [NSString stringWithFormat:@"%@<BR>", text];
  } else {
    htmlString = [NSString stringWithFormat:@"<b>%@</b>:%@<BR>"
                  , user
                  , text];
  }
  NSString *javascript = [NSString stringWithFormat:@"var div=document.createElement('div');div.innerHTML=\"%@\";document.body.appendChild(div);", htmlString]; 
  [chatWebView stringByEvaluatingJavaScriptFromString:javascript];	
	int height = [[chatWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
	javascript = [NSString stringWithFormat:@"window.scrollTo(0, %d);", height]; 
	[chatWebView stringByEvaluatingJavaScriptFromString:javascript];	
}



- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
  // only send if we're connected
  ChatAppDelegate *appDelegate = (ChatAppDelegate *)[[UIApplication sharedApplication] delegate];
	BOOL didSendMessage = [appDelegate.chatController sendMessage:textField.text fromRoom:self.title];
	
  // clear out the input box
  [textField setText:@""];
  return didSendMessage;	
}


- (void)viewDidUnload {
	[chatWebView release]; chatWebView = nil;
	[textFieldBackground release]; textFieldBackground = nil;
	[textField release]; textField = nil;
	ChatAppDelegate *appDelegate = (ChatAppDelegate *)[[UIApplication sharedApplication] delegate];
  appDelegate.chatController.delegate = nil;
}


- (void) keyboardWillShow:(NSNotification *) note {
	// get the frame and center of the keyboard so we can move the textField
  CGRect keyboardFrame;
  [[note.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue: &keyboardFrame];
  CGPoint keyboardCenter; 
  [[note.userInfo valueForKey:UIKeyboardCenterEndUserInfoKey] getValue: &keyboardCenter];
  
  // make a copy of the textField background frame so we can modify it
  CGRect newTextFieldBGFrame  = textFieldBackground.frame;
	
	CGRect newChatWebViewFrame = chatWebView.frame;
	
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
	
	// reduce the size of the webView to make room for the keyboard and textField
	newChatWebViewFrame.size.height =  
  self.view.frame.size.height 
	- keyboardFrame.size.height 
	- TEXTFIELD_BG_HEIGHT;
	// assign the new frame back to the webView's frame
  chatWebView.frame = newChatWebViewFrame;
}


- (void)viewDidLoad {
	// check with the chatController for a connection, or wait for the connection
	[super viewDidLoad];
	
	// create the webView that shows the chat
	chatWebView = [[UIWebView alloc]initWithFrame:self.view.bounds];
  [chatWebView loadHTMLString:@"<html><body>Welcome!<BR></body></html>" baseURL:nil];
	chatWebView.delegate = self;
	[self.view addSubview:chatWebView];
  
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
