//
//  RoomTableViewController.m
//  Chat
//
//  Created by EFB on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RoomTableViewController.h"
#import "ChatViewController.h"
#import "ChatAppDelegate.h"
#import "ProfileViewController.h"

@implementation RoomTableViewController


#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
	// Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
	self = [super initWithStyle:style];
	if (self) {
		self.title = @"Rooms";
	}
	
	UIBarButtonItem *profileButton = [[[UIBarButtonItem alloc]initWithTitle:@"My Profile" 
																																		style:UIBarButtonItemStyleBordered 
																																	 target:self 
																																	 action:@selector(showProfileScreen)]autorelease];
	self.navigationItem.rightBarButtonItem = profileButton;
	
	UIView *roomFieldBackground = [[[UIView alloc]initWithFrame:														 
																	CGRectMake(0,0,self.view.frame.size.width,35)]autorelease];
	roomFieldBackground.backgroundColor = [UIColor blueColor];		
	UITextField *roomField = [[[UITextField alloc]initWithFrame:
														 CGRectMake(5,5,self.view.frame.size.width-10,25)]autorelease];
	roomField.placeholder = @"Enter the name of a new room";
	roomField.borderStyle = UITextBorderStyleRoundedRect;
	roomField.returnKeyType = UIReturnKeyDone;
	roomField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	roomField.delegate = self;
	[roomFieldBackground addSubview:roomField];
	self.tableView.tableHeaderView = roomFieldBackground;	
	return self;
}


- (void) joinRoom:(NSString*)roomName {
	ChatViewController *chatViewController = [[[ChatViewController alloc] init]autorelease];
	chatViewController.title = roomName;
  
	ChatAppDelegate *appDelegate = (ChatAppDelegate *)[[UIApplication sharedApplication] delegate];
  [appDelegate.chatController joinRoom:roomName];
  appDelegate.chatController.delegate = chatViewController;
	
	[self.navigationController pushViewController:chatViewController animated:YES];
}	


#pragma mark -
#pragma mark ChatController delegate methods

- (void) didReceiveRoomList {
	[self.navigationController
	 dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UITextField delegate methods

// save the room after the user presses done
- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self joinRoom:textField.text];
	
	// breaks MVC - ghetto adding the room to the list as it's made
	[listOfRooms insertObject:textField.text atIndex:0];
  [self.tableView reloadData];
}


// hide the keyboard when the user presses Done
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;  
}


- (void) showProfileScreen {
	ProfileViewController *pvc = [[[ProfileViewController alloc]init]autorelease];
	[self.navigationController pushViewController:pvc animated:YES];
}


// delegate function for ChatController
- (void)updateList:(NSArray *)roomList {
  [listOfRooms release];
  listOfRooms = [[NSMutableArray alloc] init];
  for (id room in roomList) {
    [listOfRooms addObject:room];
  }
  [self.tableView reloadData];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
	// self.navigationController.navigationBarHidden = YES;   
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
	ChatAppDelegate *appDelegate = (ChatAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.chatController.delegate = self;
}

/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }


- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}
 */


/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
	 return YES;
 }


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	return [listOfRooms count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	cell.textLabel.text = [listOfRooms objectAtIndex:indexPath.row];
	
	return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// create and push a ChatViewController
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  NSString *roomName = cell.textLabel.text;
	[self joinRoom:roomName];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	// For example: self.myOutlet = nil;
}


- (void)dealloc {
	[super dealloc];
}


@end

