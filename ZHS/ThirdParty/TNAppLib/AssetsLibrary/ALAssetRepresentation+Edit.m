//
//  ALAssetRepresentation+Edit.m
//  WeZone
//
//  Created by kiri on 2014-02-24.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "ALAssetRepresentation+Edit.h"

@implementation ALAssetRepresentation (Edit)

- (UIImage *)editedFullResolutionImage
{
    CGImageRef fullResImage = [self fullResolutionImage];
    if (fullResImage == NULL) {
        return nil;
    }
    
    NSString *adjustment = [[self metadata] objectForKey:@"AdjustmentXMP"];
    if (adjustment) {
        NSData *xmpData = [adjustment dataUsingEncoding:NSUTF8StringEncoding];
        CIImage *image = [CIImage imageWithCGImage:fullResImage];
        
        NSError *error = nil;
        NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:xmpData
                                                     inputImageExtent:image.extent
                                                                error:&error];
        CIContext *context = [CIContext contextWithOptions:nil];
        if (filterArray && !error) {
            for (CIFilter *filter in filterArray) {
                [filter setValue:image forKey:kCIInputImageKey];
                image = [filter outputImage];
            }
            fullResImage = [context createCGImage:image fromRect:[image extent]];
            UIImage *image = [UIImage imageWithCGImage:fullResImage scale:[self scale] orientation:(int)[self orientation]];
            CGImageRelease(fullResImage);
            
            return image;
        }
    }
    
    return [UIImage imageWithCGImage:fullResImage scale:[self scale] orientation:(int)[self orientation]];
}

@end
