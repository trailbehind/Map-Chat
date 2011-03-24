//
//  CameraController.h
//  TrailTracker
//
//  Created by Andrew Johnson on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CameraController :  UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {

	id editedObject;
	NSString *mode;
	BOOL movieIsAvailable;
	UITextField *photoTitleField;
  NSDictionary *photoInfo;
  NSData* compressedImage;
  NSString* photoTitle;
  BOOL doneSavingToAlbum;

}

@property (nonatomic, retain) NSData* compressedImage;
@property (nonatomic, retain) id editedObject;
@property (nonatomic, retain) NSString *mode, *photoTitle;
@property (nonatomic) BOOL movieIsAvailable;
@property (nonatomic, retain) NSDictionary *photoInfo;
@property (nonatomic, assign) BOOL doneSavingToAlbum;


- (id) initWithMode:(NSString *) aMode;


    
@end