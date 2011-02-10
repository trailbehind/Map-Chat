//
//  ChatController.h
//  Chat
//
//  Created by EFB on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIoClient.h"

@protocol ChatControllerDelegate <NSObject>

@optional
- (void) write:(NSString*)text user:(NSString*)user;

@optional
- (void) updateList:(NSDictionary*)roomList;

@optional
- (void) didSaveName:(BOOL)didSucceed;

@optional
- (void) didSaveEmail:(BOOL)didSucceed;

@end


@interface ChatController : NSObject <SocketIoClientDelegate> {
	
	SocketIoClient *client;
	id <ChatControllerDelegate> delegate;
  id <ChatControllerDelegate> roomTableViewControllerDelegate;
	
}

@property(nonatomic,assign) id <ChatControllerDelegate> delegate;
@property(nonatomic,assign) id <ChatControllerDelegate> roomTableViewControllerDelegate;

- (void) connect;
- (BOOL) sendMessage:(NSString*)text;
- (void) saveEmail:(NSString*)email;
- (void) saveNickname:(NSString*)nickname;


@end
