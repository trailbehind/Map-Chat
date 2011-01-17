//
//  ChatController.h
//  Chat
//
//  Created by EFB on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIoClient.h"

@protocol ChatControllerDelegate

- (void) write:(NSString*)text;

@end


@interface ChatController : NSObject <SocketIoClientDelegate> {
	
	SocketIoClient *client;
	id <ChatControllerDelegate> delegate;
	
}

@property(nonatomic,assign) id <ChatControllerDelegate> delegate;


- (void) connect;
- (BOOL) sendMessage:(NSString*)text;
// - (void)reconnect:(id)sender;


@end
