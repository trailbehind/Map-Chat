//
//  ChatViewController.m
//  Chat
//

#import "ChatViewController.h"

@implementation ChatViewController

- (void)log:(NSString *)message {
	NSLog(@"%@", message);
}

-(void)write:(NSString*)text {
    NSMutableString* newText = [NSMutableString stringWithString:textView.text];
    [newText appendString:text];
    [newText appendString:@"\n"];
    textView.text = newText;
    [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];
}

- (void)onChatMessage:(NSDictionary *)msgObj {
	NSString *formattedMsg;
	formattedMsg = [NSString stringWithFormat: @"%@: %@", [msgObj objectForKey:@"username"], [msgObj objectForKey:@"message"]];
	[self write:formattedMsg];	
}

- (void)onAnnouncement:(NSDictionary *)msgObj {
	NSString *formattedMsg;
	formattedMsg = [NSString stringWithFormat: @"** %@ **", [msgObj objectForKey:@"announcement"]];
	[self write:formattedMsg];
}

- (void)onMessage:(NSDictionary *) msgObj {
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
	reconnectButton.hidden = YES;
	NSString* host = @"173.203.56.222";
	NSInteger* port = 9202;
	
	client = [[SocketIoClient alloc] initWithHost:host port:port];
	client.delegate = self;
	
	[client connect];	
}


 - (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	if ([client isConnected]) {
		NSDictionary *dictionary = [NSDictionary dictionaryWithObject:aTextField.text forKey:@"msg"];
		NSError *error = NULL;
		NSData *jsonData = [[CJSONSerializer serializer] serializeObject:dictionary error:error];
		NSString *jsonDataStr = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
		
		[client send:jsonDataStr isJSON:NO];
		[self write:textField.text];
	} else {
		[self write:@"Not connected."];
	}
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
	
	// the payloads aren't being recognized as JSON right now, but they are.
	if (TRUE) {
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
	} else {
		[self write:msg];
	}
}

-(void)viewDidLoad {
	// init
	[self connect];
	
	[textView becomeFirstResponder];
    [textField becomeFirstResponder];
}

-(void)dealloc {
    [super dealloc];
}

@end
