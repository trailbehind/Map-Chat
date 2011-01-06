//
//  ChatViewController.m
//  Chat
//

#import "ChatViewController.h"

@implementation ChatViewController

-(void)dealloc {
  [client release];
  [super dealloc];
}

- (void)log:(NSString *)message {
  NSLog(@"%@", message);
}

-(void)write:(NSString*)text {
  // write raw text to the textView
  NSMutableString* newText = [NSMutableString stringWithString:textView.text];
  [newText appendString:text];
  [newText appendString:@"\n"];
  textView.text = newText;
  [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];
}

- (void)onChatMessage:(NSDictionary *)msgObj {
  // print a message e.g. "user: msg"
  NSString *formattedMsg;
  formattedMsg = [NSString stringWithFormat: @"%@: %@", [msgObj objectForKey:@"username"], [msgObj objectForKey:@"message"]];
  [self write:formattedMsg];	
}

- (void)onAnnouncement:(NSDictionary *)msgObj {
  // print an announcement e.g. "** msg **"
  NSString *formattedMsg;
  formattedMsg = [NSString stringWithFormat: @"** %@ **", [msgObj objectForKey:@"announcement"]];
  [self write:formattedMsg];
}

- (void)onMessage:(NSDictionary *) msgObj {
  // strategy for different types of objects
  BOOL isAnnouncement = ([msgObj objectForKey:@"announcement"] != nil);
  if (isAnnouncement) {
    [self onAnnouncement:msgObj];
  } else {
    [self onChatMessage:msgObj];
  }
}

- (void)disconnect {
  [client disconnect];
}

- (void)connect {
  // TODO: make sure the reconnect button is working correctly
  reconnectButton.hidden = YES;
  // hardcoded for now
  NSString* host = @"173.203.56.222";
  NSInteger* port = 9202;
  
  // setup and connect to the server with websockets
  client = [[SocketIoClient alloc] initWithHost:host port:port];
  client.delegate = self;
  
  [client connect];	
}


- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
  // only send if we're connected
  if ([client isConnected]) {
    // encode the message in JSON
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:aTextField.text forKey:@"msg"];
    NSError *error = NULL;
    NSData *jsonData = [[CJSONSerializer serializer] serializeObject:dictionary error:error];
    NSString *jsonDataStr = [[[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding]autorelease];
		
    [client send:jsonDataStr isJSON:NO];
    [self write:textField.text];
  } else {
    [self write:@"Not connected."];
  }
  // clear out the input box
  [textField setText:@""];
  return NO;	
}

-(IBAction)reconnect:(id)sender {
  if (![client isConnected]) {
    [self connect];
  }
}

- (void)socketIoClientDidConnect:(SocketIoClient *)client {
  NSLog(@"Connected.");
}

- (void)socketIoClientDidDisconnect:(SocketIoClient *)client {
  NSLog(@"Disconnected.");
  [self write:@"Disconnected."];
  reconnectButton.hidden = NO;
}

- (void)socketIoClient:(SocketIoClient *)client didReceiveMessage:(NSString *)msg isJSON:(BOOL)isJSON {
  NSLog(@"Received: %@", msg);
	
  // TODO: either assume it's always JSON or get the server to send the "correct" frame.
  // decode JSON
  NSError *error = nil;
  NSDictionary *jsonDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:[msg dataUsingEncoding:NSUTF32BigEndianStringEncoding] error:&error];
		
  // process resulting data
  if ([jsonDict objectForKey:@"userlist"] == nil) {
    BOOL multipleMessages = ([jsonDict objectForKey:@"messages"] != nil);
    if (multipleMessages) {
      for (NSString* key in jsonDict) {
        id value = [jsonDict objectForKey:key];
        for (id someMsg in value) {
          [self onMessage:someMsg];
        }
      }
    } else {
      [self onMessage:jsonDict];
    }
  }
}

-(void)viewDidLoad {
  // init
  [self connect];
	
  [textView becomeFirstResponder];
  [textField becomeFirstResponder];
}


@end
