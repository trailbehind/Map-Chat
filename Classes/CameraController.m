//
//  CameraController.m
//  TrailTracker
//
//  Created by Andrew Johnson on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CameraController.h"
#import <CoreLocation/CoreLocation.h>
#import "ImageManipulator.h"
#import <CoreData/CoreData.h>
@implementation CameraController

#define SOURCETYPE UIImagePickerControllerSourceTypeCamera 


@synthesize mode, editedObject, movieIsAvailable, photoInfo, compressedImage, photoTitle,
  doneSavingToAlbum;

- (id) initWithMode:(NSString *) aMode { 

	if (!(self = [super init])) return self; 
	
	self.mode = [NSString stringWithFormat:@"%@", aMode];	
	// Set up the source 
	if ([UIImagePickerController isSourceTypeAvailable:SOURCETYPE]) 
		self.sourceType = SOURCETYPE; 
	if([self.mode isEqualToString:@"camera"]){
		self.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
	}
	self.delegate = self; 
  
  return self; 

}


- (void) compressImageThreaded:(UIImage*) img {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  self.compressedImage = UIImageJPEGRepresentation(img,.8);
  UIImage* image = [ImageManipulator scaleAndRotateImage:img]; 
  //NSLog(@"time to scale and rotate uncompressed %f", -[startTime timeIntervalSinceNow]);
  image = [UIImage imageWithData:self.compressedImage];
  image = [ImageManipulator scaleAndRotateImage:image]; 
  //NSLog(@"time to scale and rotate compressed %f", -[startTime timeIntervalSinceNow]);

  
  
  [pool release];
  
}


- (NSString*) getDirectory {
	id t = [[UIApplication sharedApplication] delegate];
	NSString *photoPath = [@"/photos/" stringByAppendingString:[self title]];
  photoPath = [[t applicationDocumentsDirectory] stringByAppendingString: photoPath];
  return photoPath;
}


- (void) saveToDisk:(NSData*)photoData suffix:(NSString*)suffix {
  NSString* filePath = [self getDirectory];
  NSFileManager* fileManager = [NSFileManager defaultManager];
  filePath = [filePath stringByAppendingString: @"/"];
	[fileManager createDirectoryAtPath: filePath withIntermediateDirectories:YES attributes: nil error: nil];
	
  if (suffix) {
    filePath = [filePath stringByAppendingString:suffix];
  }
  [fileManager createFileAtPath:filePath contents:nil attributes:nil];
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];			
  [fileHandle writeData:photoData];
 	[fileHandle closeFile];	  
}



- (void) saveImage:(CameraController*) cam { 
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
  while (!compressedImage) {
    [NSThread sleepForTimeInterval:.2];
  }
  
  NSData* imgData = cam.compressedImage;
  UIImage* compImage = [UIImage imageWithData:imgData];

  UIImage* scaledImg = [ImageManipulator scalePhotoToStandard:compImage];
  scaledImg = [ImageManipulator scaleAndRotateImage:scaledImg]; 	
  NSData* scaledImgData = UIImageJPEGRepresentation(scaledImg,.5);
	[self saveToDisk:scaledImgData suffix:@"scaled"];
	  
  UIImage *thumbData = [[ImageManipulator scalePhoto:scaledImg minHeight:40 minWidth:40]retain];  
  [self saveToDisk:UIImageJPEGRepresentation(thumbData, .3) suffix:@"thumb"];
  [thumbData release];
  
  //  UIImageWriteToSavedPhotosAlbum (compressedImage, self, 
  //                                  @selector(image:didFinishSavingWithError:contextInfo:), nil);
  
  [pool release];	
}




- (void)imagePickerController:(UIImagePickerController *)picker 
           didFinishPickingMediaWithInfo:(NSDictionary *)info {
  self.compressedImage = nil;
  
  [NSThread detachNewThreadSelector:@selector(compressImageThreaded:) toTarget:self 
                        withObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
  [[self parentViewController] dismissModalViewControllerAnimated:YES];  
  [photoInfo release];
  photoInfo = nil;
	[NSThread detachNewThreadSelector:@selector(saveImage:) toTarget:self
                         withObject:self];
}


- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}


- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}


- (void)dealloc {
	[mode release];
	[photoInfo release];
  [photoTitle release];
  [compressedImage release];
	[super dealloc];
}

@end


