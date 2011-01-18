//
//  ChatController.m
//  Chat
//

#import "ChatController.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"


@implementation ChatController
@synthesize delegate, roomTableViewControllerDelegate;

- (void)dealloc {
  [client release];
  [super dealloc];
}


- (void)onChatMessage:(NSDictionary *)msgObj {
  // print a message e.g. "user: msg"
  NSString *formattedMsg;
  formattedMsg = [NSString stringWithFormat: @"%@: %@", [msgObj objectForKey:@"username"], [msgObj objectForKey:@"message"]];
  [self.delegate write:formattedMsg];	
}


- (void)onAnnouncement:(NSDictionary *)msgObj {
  // print an announcement e.g. "* msg *"
  NSString *formattedMsg;
  formattedMsg = [NSString stringWithFormat: @"* %@ *", [msgObj objectForKey:@"announcement"]];
  [self.delegate write:formattedMsg];
}

- (void)onRoomList:(NSDictionary *)msgObj {
  NSLog(@"At onRoomList");
  [self.roomTableViewControllerDelegate updateList:(NSArray*)[msgObj objectForKey:@"rooms"]];
  
}

- (void)onMessage:(NSDictionary *) msgObj {
  // strategy for different types of objects
  BOOL isAnnouncement = ([msgObj objectForKey:@"announcement"] != nil);
  BOOL isChatMessage = ([msgObj objectForKey:@"message"] != nil);
  BOOL isRoomList = ([msgObj objectForKey:@"rooms"] != nil);
  if (isAnnouncement) {
    [self onAnnouncement:msgObj];
  } else if (isChatMessage) {
    [self onChatMessage:msgObj];
  } else if (isRoomList) {
    [self onRoomList:msgObj];
    // probably metadata
  }
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


- (void)socketIoClientDidConnect:(SocketIoClient *)client {
  NSLog(@"Connected.");
}

- (void)socketIoClientDidDisconnect:(SocketIoClient *)client {
  NSLog(@"Disconnected.");
  [self.delegate write:@"Disconnected."];
}


- (void)connect {
  // hardcoded for now
  NSString *host = @"173.203.56.222";
  NSInteger port = 9202;
  
  // setup and connect to the server with websockets
  client = [[SocketIoClient alloc] initWithHost:host port:port];
  client.delegate = self;
  
  [client connect];	
}


- (void)disconnect {
  [client disconnect];
}


- (BOOL) sendJson:(NSDictionary*)dictionary {
  if ([client isConnected]) {
    // encode the message in JSON
    NSError *error = NULL;
    NSData *jsonData = [[CJSONSerializer serializer] serializeObject:dictionary error:&error];
    NSString *jsonDataStr = [[[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding]autorelease];
		
    [client send:jsonDataStr isJSON:NO];
		return YES;
  } else {
    [self.delegate write:@"Not connected."];
    [self connect];
  }
	return NO;
  
}


- (BOOL) sendMessage:(NSString*)text {
  NSDictionary *dictionary = [NSDictionary dictionaryWithObject:text forKey:@"msg"];
  return [self sendJson:dictionary];
}


- (BOOL) joinRoom:(NSString*)text {
  NSDictionary *dictionary = [NSDictionary dictionaryWithObject:text forKey:@"joinRoom"];
  return [self sendJson:dictionary];
}


@end
