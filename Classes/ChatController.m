//
//  ChatController.m
//  Chat
//

#import "ChatController.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"


@implementation ChatController
@synthesize delegate, roomTableViewControllerDelegate;


# pragma mark -
# pragma mark methods for memory management

- (void)dealloc {
  [client release];
  [super dealloc];
}


# pragma mark -
# pragma mark methods for connect/disconnect

- (void)connect {
  // hardcoded for now
  NSString *host = @"localhost"; //@"173.203.56.222";
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
  NSDictionary *dictionary = [NSDictionary dictionaryWithObject:email forKey:@"email"];
  [self sendJson:dictionary];
}


- (void) saveNickname:(NSString*)nickname {
  NSDictionary *dictionary = [NSDictionary dictionaryWithObject:nickname forKey:@"nick"];
  [self sendJson:dictionary];
}


- (BOOL) sendMessage:(NSString*)text fromRoom:(NSString*)roomName {
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
															text, @"msg", roomName, @"room_name", nil];
  return [self sendJson:dictionary];
}


- (BOOL) joinRoom:(NSString*)text {
  NSDictionary *dictionary = [NSDictionary dictionaryWithObject:text forKey:@"joinRoom"];
  return [self sendJson:dictionary];
}


- (void) sendUDID {
  NSDictionary *dictionary = [NSDictionary dictionaryWithObject:
															[[UIDevice currentDevice] uniqueIdentifier] forKey:@"login"];
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
  // print a message e.g. "user: msg"
	if ([self.delegate respondsToSelector:@selector(write:user:)])
    [self.delegate write:[msgObj objectForKey:@"message"] user:[msgObj objectForKey:@"username"]];	
}


- (void)onAnnouncement:(NSDictionary *)msgObj {
  // print an announcement e.g. "* msg *"
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
