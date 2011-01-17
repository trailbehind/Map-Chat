//
//  ChatAppDelegate.h
//  Chat
//

#import <UIKit/UIKit.h>

@class ChatViewController, RoomTableViewController, ChatController;

@interface ChatAppDelegate : NSObject <UIApplicationDelegate> {
    
	UIWindow *window;
	
	RoomTableViewController *roomTableViewController;
	UINavigationController *roomNavController;
	
	ChatController *chatController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) ChatController *chatController;

@end

