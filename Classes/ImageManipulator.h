//
//  ImageManipulator.h
//  udorse

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ImageManipulator : NSObject { }

+ (UIImage*)scaleAndRotateImage:(UIImage *)image;

+ (UIImage*) scalePhoto:(UIImage*)image 
              maxHeight:(float)maxHeight;

+ (UIImage*) scalePhoto:(UIImage*)image 
              minHeight:(float)minHeight
               minWidth:(float)minWidth;
  
+ (NSMutableData*) tagImageData:(NSData*)imgData withLocation:(CLLocation*)location;

+ (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle;
+ (UIImage*) scalePhotoToStandard:(UIImage*) img;
+ (UIImage*) cropIcon24:(UIImage*)icon;
+ (UIImage*) cropIcon32:(UIImage*)icon;


@end
