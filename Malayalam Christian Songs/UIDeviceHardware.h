//
//  UIDeviceHardware.h
//  
//
//  Created by jijo on 26/02/10. This file/source is from Jason Goldberg
//  
//

#import <Foundation/Foundation.h>


@interface UIDeviceHardware : NSObject 


+(BOOL) isOS4Device;
+(BOOL) isOS5Device;
+(BOOL) isOS6Device;
+(BOOL) isOS7Device;
+(BOOL) isOS8Device;
+(BOOL) isIpad;
+(BOOL)isSupportRotation:(UIInterfaceOrientation)interfaceOrientation;

@end
