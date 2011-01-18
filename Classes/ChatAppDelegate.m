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


- (BOOL)application:(UIApplication *)application 
	 didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
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
	
	return YES;
}


@end
