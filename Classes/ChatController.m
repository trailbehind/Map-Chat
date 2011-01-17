//
//  ChatController.m
//  Chat
//

#import "ChatController.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"


@implementation ChatController
@synthesize delegate;

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
  // print an announcement e.g. "** msg **"
  NSString *formattedMsg;
  formattedMsg = [NSString stringWithFormat: @"** %@ **", [msgObj objectForKey:@"announcement"]];
  [self.delegate write:formattedMsg];
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


- (BOOL) sendMessage:(NSString*)text {
	if ([client isConnected]) {
    // encode the message in JSON
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:text forKey:@"msg"];
    NSError *error = NULL;
    NSData *jsonData = [[CJSONSerializer serializer] serializeObject:dictionary error:&error];
    NSString *jsonDataStr = [[[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding]autorelease];
		
    [client send:jsonDataStr isJSON:NO];
    [self.delegate write:text];
		return YES;
  } else {
    [self.delegate write:@"Not connected."];
  }
	return NO;
}

//- (void)reconnect:(id)sender {
//  if (![client isConnected]) {
//    [self connect];
//  }
//}


@end
