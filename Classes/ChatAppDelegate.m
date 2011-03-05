//
//  ChatAppDelegate.m
//  Chat
//

#import "ChatAppDelegate.h"
#import "ChatViewController.h"
#import	"RoomTableViewController.h"
#import "ChatController.h"

@implementation ChatAppDelegate
@synthesize window, chatController;

- (void)dealloc {
	[chatController release];
	[roomTableViewController release];
	[roomNavController release];
	[window release];
	[super dealloc];
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  // const void *devTokenBytes = [deviceToken bytes];
  NSLog(@"the token is %@", deviceToken);
  // self.registered = YES;
  // [self sendProviderDeviceToken:devTokenBytes]; // custom method
}


- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
  NSLog(@"Error in registration. Error: %@", err);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //NSString *itemName = [userInfo objectForKey:ToDoItemKey];
    UIAlertView *av = [[[UIAlertView alloc]initWithTitle:@"Pushed, already running" message:@"The app received a notification while running" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]autorelease];
    [av show];
    //application.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber-1;
}


- (BOOL)application:(UIApplication *)application 
	 didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
  
  //register for badge and sound pushes
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];

  // respond to a push if the app wasn't running
  UILocalNotification *localNotif =
  [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
  if (localNotif) {
    // NSString *itemName = [localNotif.userInfo objectForKey:ToDoItemKey];
    UIAlertView *av = [[[UIAlertView alloc]initWithTitle:@"Pushed on start" message:@"The app received a notification and then started up" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]autorelease];
    [av show];
    //application.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber-1;
  }

	chatController = [[ChatController alloc]init];
	[chatController connect];
	
  // init the table of rooms 
	roomTableViewController = [[RoomTableViewController alloc]initWithStyle:UITableViewStylePlain];
  chatController.roomTableViewControllerDelegate = roomTableViewController;

	// create a navigationController (which shows the top bar) 
	// and make the roomTableViewController the main view
	roomNavController = [[UINavigationController alloc]initWithRootViewController:roomTableViewController];
	roomNavController.navigationBar.barStyle = UIBarStyleBlack;
	  
	// add the navigationController's view to the window
	[window addSubview:roomNavController.view];
	
	// start showing stuff on the screen
	[window makeKeyAndVisible];
	
  NSLog(@"Application finished launching");

  
	UIViewController *vc = [[[UIViewController alloc]init]autorelease];
	[roomNavController presentModalViewController:vc animated:NO];
	
	return YES;
}


@end
