//
//  ImageManipulator.m
//  Udorse
//

#import "ImageManipulator.h"

@implementation ImageManipulator

// Scale a photo to fit in a given max height, with padding
+ (UIImage*) scalePhoto:(UIImage*)image 
              maxHeight:(float)maxHeight {
  
  float imgWidth = image.size.width;
  float imgHeight = image.size.height;
    
  float maxPhotoWidth = 320;

  if ([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft
      || [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight) {
    maxPhotoWidth = 480;
  }
  float maxPhotoHeight = maxHeight;
  float scale = MAX(imgWidth / maxPhotoWidth, imgHeight / maxPhotoHeight);
  imgHeight /= scale;
  imgWidth /= scale;

  CGSize newSize = CGSizeMake(imgWidth, imgHeight);
  UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
  
}

+ (UIImage*) scalePhotoToStandard:(UIImage*) img {
  CGSize smallSize = CGSizeMake(img.size.width/2, img.size.height/2);
  
  //NSLog(@"before scaling small photo %f", -[startTime timeIntervalSinceNow]);
  UIImage* scaledImg = [ImageManipulator scalePhoto:img 
                                          minHeight:smallSize.height 
                                           minWidth:smallSize.width];
  
  //NSLog(@" after scaling small photo %f", -[startTime timeIntervalSinceNow]);
  return scaledImg;
}


// scale photos to min heigth/width, to make thumbnails
+ (UIImage*) scalePhoto:(UIImage*)image 
              minHeight:(float)minHeight
               minWidth:(float)minWidth {
  
  float imgWidth = image.size.width;
  float imgHeight = image.size.height;
  
  float scale = MIN(imgWidth / minWidth, imgHeight / minHeight);
  imgHeight /= scale;
  imgWidth /= scale;
  
  CGSize newSize = CGSizeMake(imgWidth, imgHeight);
  UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
  
}


// orient photos and scale them to kMaxResolution 
+ (UIImage*)scaleAndRotateImage:(UIImage *)image {
  
  @synchronized(self) {
    // we upload photos at a maximum resolution of 2048 x 1536
    int kMaxResolution = 2048; 
    //NSLog (@"img height and width are %f, %f", image.size.height, image.size.width);

    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
      CGFloat ratio = width/height;
      if (ratio > 1) {
        bounds.size.width = kMaxResolution;
        bounds.size.height = bounds.size.width / ratio;
      } else {
        bounds.size.height = kMaxResolution;
        bounds.size.width = bounds.size.height * ratio;
      }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
        
      case UIImageOrientationUp: //EXIF = 1
        transform = CGAffineTransformIdentity;
        break;
        
      case UIImageOrientationUpMirrored: //EXIF = 2
        transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
        transform = CGAffineTransformScale(transform, -1.0, 1.0);
        break;
        
      case UIImageOrientationDown: //EXIF = 3
        transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        break;
        
      case UIImageOrientationDownMirrored: //EXIF = 4
        transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
        transform = CGAffineTransformScale(transform, 1.0, -1.0);
        break;
        
      case UIImageOrientationLeftMirrored: //EXIF = 5
        boundHeight = bounds.size.height;
        bounds.size.height = bounds.size.width;
        bounds.size.width = boundHeight;
        transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
        transform = CGAffineTransformScale(transform, -1.0, 1.0);
        transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
        break;
        
      case UIImageOrientationLeft: //EXIF = 6
        boundHeight = bounds.size.height;
        bounds.size.height = bounds.size.width;
        bounds.size.width = boundHeight;
        transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
        transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
        break;
        
      case UIImageOrientationRightMirrored: //EXIF = 7
        boundHeight = bounds.size.height;
        bounds.size.height = bounds.size.width;
        bounds.size.width = boundHeight;
        transform = CGAffineTransformMakeScale(-1.0, 1.0);
        transform = CGAffineTransformRotate(transform, M_PI / 2.0);
        break;
        
      case UIImageOrientationRight: //EXIF = 8
        boundHeight = bounds.size.height;
        bounds.size.height = bounds.size.width;
        bounds.size.width = boundHeight;
        transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
        transform = CGAffineTransformRotate(transform, M_PI / 2.0);
        break;
        
      default:
        [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
        
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
      CGContextScaleCTM(context, -scaleRatio, scaleRatio);
      CGContextTranslateCTM(context, -height, 0);
    }
    else {
      CGContextScaleCTM(context, scaleRatio, -scaleRatio);
      CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
  }
}


// kudos - http://blog.coriolis.ch/2009/09/04/arbitrary-rotation-of-a-cgimage/
+ (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle {
  CGFloat angleInRadians = angle * (M_PI / 180);
  CGFloat width = CGImageGetWidth(imgRef);
  CGFloat height = CGImageGetHeight(imgRef);
  CGRect imgRect = CGRectMake(0, 0, width, height);
  CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
  CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef bmContext = CGBitmapContextCreate(NULL,
                                                 rotatedRect.size.width,
                                                 rotatedRect.size.height,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
  CGColorSpaceRelease(colorSpace);
  CGContextTranslateCTM(bmContext,
                        +(rotatedRect.size.width/2),
                        +(rotatedRect.size.height/2));
  CGContextRotateCTM(bmContext, angleInRadians);
  CGContextTranslateCTM(bmContext,
                        -(rotatedRect.size.width/2),
                        -(rotatedRect.size.height/2));
  
  CGContextDrawImage(bmContext, CGRectMake(0,
                                           0,
                                           rotatedRect.size.width,
                                           rotatedRect.size.height),
                     imgRef);
  
  CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
  CFRelease(bmContext);
  [(id)rotatedImage autorelease];
  
  return rotatedImage;
}


+ (CGFloat) mainScreenScale {
  CGFloat scale = 1.0;
  UIScreen* screen = [UIScreen mainScreen];
  if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
    scale = [screen scale];
  }
  return scale;
}


+ (BOOL) screenIs2xResolution {
  return 2.0 == [ImageManipulator mainScreenScale];
}


+ (UIImage*) cropIcon24:(UIImage*)icon {
  CGRect cropRect = CGRectMake(4,4,24,24);  
	if([ImageManipulator screenIs2xResolution]) {
    cropRect = CGRectMake(8,8,48,48);
  }
  
  CGImageRef imageRef = CGImageCreateWithImageInRect([icon CGImage], cropRect);
  UIImage *newIcon = [UIImage imageWithCGImage:imageRef]; 
  CGImageRelease(imageRef);
  return newIcon;
} 


+ (UIImage*) cropIcon32:(UIImage*)icon {
  CGRect cropRect = CGRectMake(8,8,32,32);
  CGImageRef imageRef = CGImageCreateWithImageInRect([icon CGImage], cropRect);
  UIImage *newIcon = [UIImage imageWithCGImage:imageRef]; 
  CGImageRelease(imageRef);
  return newIcon;
} 




@end
