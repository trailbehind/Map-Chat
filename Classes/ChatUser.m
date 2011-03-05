//
//  ChatUser.m
//  Chat
//
//  Created by Admin on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatUser.h"


@implementation ChatUser
@synthesize username, email;


- (void) dealloc {
  [username release];
  [email release];
  [super dealloc];
}


@end
