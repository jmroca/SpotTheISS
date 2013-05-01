//
//  ImageUtils.h
//  iSticker Albums
//
//  Created by Jose De La Roca on 9/7/12.
//
//

#import <Foundation/Foundation.h>
#import "DefineConst.h"

@interface ImageUtils : NSObject


// crear una imagen de diferente tamanio a partir de una imagen
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

// crear una imagen de diferente tamanio a partir de una imagen
+ (UIImage*)imageWithImageCG:(UIImage*)image scaledToSize:(CGSize)newSize;

// redimensionar una imagen con CoreGraphics
+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;

+(UIImage*) generateImageFromView:(UIView*) theView;


@end
