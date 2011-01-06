//
//  ChatAppDelegate.h
//  Chat
//

#import <UIKit/UIKit.h>

@class ChatViewController;

@interface ChatAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ChatViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ChatViewController *viewController;

@end

