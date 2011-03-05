//
//  ChatController.m
//  Chat
//

#import "ChatController.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "ChatUser.h"

@implementation ChatController
@synthesize delegate, roomTableViewControllerDelegate, user;


# pragma mark -
# pragma mark methods for memory management

- (void)dealloc {
  [client release];
  [user release];
  [super dealloc];
}


# pragma mark -
# pragma mark init methods

- (id) init {
  self = [super init];
  user = [[ChatUser alloc]init];
  return self;
}


# pragma mark -
# pragma mark methods for connect/disconnect

- (void)connect {
  // hardcoded for now
  NSString *host = @"173.203.56.222";
  NSInteger port = 9202;
  
  // setup and connect to the server with websockets
  client = [[SocketIoClient alloc] initWithHost:host port:port];
  client.delegate = self;
  
  [client connect];
	
	// Dan: set a callback here to maybeSendPendingJson on connect success
}


- (void)disconnect {
  [client disconnect];
}

// Send any pending messages. If we're not connected, this will connect first.
- (void)maybeSendPendingJson {
	/*
  if (pending_jsons.length == 0) {
		return;
	}
	 
	if (!connected) {
	 connect();
	}
	 
	for (pending_json in pending_jsons) {
	 sendJson(pending_json);
	}
	 */


}


# pragma mark -
# pragma mark methods to send messages

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
-(NSString *) generateRandomString: (int) len {
	
	NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
	
	for (int i=0; i<len; i++) {
		[randomString appendFormat: @"%c", [letters characterAtIndex: arc4random()%[letters length]]];
	}
  
	return randomString;
}


// send a message as JSON to the chat server
- (BOOL) sendJson:(NSDictionary*)dictionary {
  if ([client isConnected]) {
    // encode the message in JSON
    NSError *error = NULL;
    NSData *jsonData = [[CJSONSerializer serializer] serializeObject:dictionary error:&error];
    NSString *jsonDataStr = [[[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding]autorelease];
    [client send:jsonDataStr isJSON:NO];
		return YES;
  } else {
		if ([self.delegate respondsToSelector:@selector(write:user:)]) {
      [self.delegate write:@"Not connected." user:nil];
		}
    [self connect];
  }
	return NO;
}

	 
- (void) saveEmail:(NSString*)email {
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
															[[UIDevice currentDevice] uniqueIdentifier], @"uid", 
															@"email", @"command",
                              email, @"email",
															[self generateRandomString:128], @"id", nil];
  
  [self sendJson:dictionary];
}


- (void) saveNickname:(NSString*)nickname {
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
															[[UIDevice currentDevice] uniqueIdentifier], @"uid", 
															@"nick", @"command",
                              nickname, @"nick",
															[self generateRandomString:128], @"id", nil];
  
  [self sendJson:dictionary];
}


- (BOOL) sendMessage:(NSString*)text fromRoom:(NSString*)roomName {
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
															[[UIDevice currentDevice] uniqueIdentifier], @"uid", 
															@"message", @"command",
                              roomName, @"room",
                              text, @"message",
															[self generateRandomString:128], @"id", nil];
  
  //NSDictionary *dictionary = [NSDictionary dictionaryWithObject:text forKey:@"msg"];
  return [self sendJson:dictionary];
}


- (BOOL) joinRoom:(NSString*)text {
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
															[[UIDevice currentDevice] uniqueIdentifier], @"uid", 
															@"join", @"command",
                              text, @"room",
															[self generateRandomString:128], @"id", nil];
  
  return [self sendJson:dictionary];
}


- (void) sendUDID {
  NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
															[[UIDevice currentDevice] uniqueIdentifier], @"uid", 
															@"login", @"command",
															[self generateRandomString:128], @"id", nil];
	[self sendJson:dictionary];
}


# pragma mark -
# pragma mark socketIO delegate methods

- (void)socketIoClientDidConnect:(SocketIoClient *)client {
	[self sendUDID];
}


- (void)socketIoClientDidDisconnect:(SocketIoClient *)client {
	if ([self.delegate respondsToSelector:@selector(write:user:)])
		[self.delegate write:@"Disconnected." user:nil];
}


- (void)onChatMessage:(NSDictionary *)msgObj {
  // print a message e.g. "user: message"
	if ([self.delegate respondsToSelector:@selector(write:user:)])
    [self.delegate write:[msgObj objectForKey:@"message"] user:[msgObj objectForKey:@"username"]];	
}


- (void)onAnnouncement:(NSDictionary *)msgObj {
  // print an announcement e.g. "* message *"
  NSString *formattedMsg;
  formattedMsg = [NSString stringWithFormat: @"* %@ *", [msgObj objectForKey:@"announcement"]];
	if ([self.delegate respondsToSelector:@selector(write:user:)])
    [self.delegate write:formattedMsg user:nil];	
}


- (void)onRoomList:(NSDictionary *)msgObj {
  [self.roomTableViewControllerDelegate updateList:(NSDictionary*)[msgObj objectForKey:@"rooms"]];
}


- (void)onMessage:(NSDictionary *) msgObj {
	NSLog(@"The message is %@", msgObj);
	BOOL isCallback = ([msgObj objectForKey:@"callback"] != nil);
	if (isCallback) {
		if ([[msgObj objectForKey:@"name"]isEqualToString:@"nick"]) {
			[self.delegate didSaveName:[[msgObj objectForKey:@"success"]boolValue]];
		} else if ([[msgObj objectForKey:@"name"]isEqualToString:@"email"]) {
			[self.delegate didSaveEmail:[[msgObj objectForKey:@"success"]boolValue]];
		} else if ([[msgObj objectForKey:@"name"]isEqualToString:@"login"]) {
			NSLog(@"Client did login successfully");
		}
		return;
	}
	
	// strategy for different types of objects
  BOOL isAnnouncement = ([msgObj objectForKey:@"announcement"] != nil);
  BOOL isChatMessage = ([msgObj objectForKey:@"message"] != nil);
  BOOL isRoomList = ([msgObj objectForKey:@"rooms"] != nil);
	
	if (isAnnouncement) {
		NSLog(@"the first thing that you get back is %@", msgObj);
    [self onAnnouncement:msgObj];
  } else if (isChatMessage) {
    [self onChatMessage:msgObj];
  } else if (isRoomList) {
		NSLog(@"the second thing that you get back is %@", msgObj);
    [self onRoomList:msgObj];
		[self.roomTableViewControllerDelegate didReceiveRoomList];		
  }
}


- (void)socketIoClient:(SocketIoClient *)client didReceiveMessage:(NSString *)msg isJSON:(BOOL)isJSON {
  NSError *error = nil;
  NSDictionary *jsonDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:[msg dataUsingEncoding:NSUTF32BigEndianStringEncoding] error:&error];
	
  if (error) {
    NSLog(@"error in json deserialization: %@", error);
  }
  
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


@end
