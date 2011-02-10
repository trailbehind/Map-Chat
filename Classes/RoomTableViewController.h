//
//  RoomTableViewController.h
//  Chat
//
//  Created by EFB on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatController.h"


@interface RoomTableViewController : UITableViewController <UITextFieldDelegate, ChatControllerDelegate> {
  NSMutableArray *listOfRooms;
}

@end

