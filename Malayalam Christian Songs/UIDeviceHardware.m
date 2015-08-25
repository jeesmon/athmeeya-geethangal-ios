//
//  UIDeviceHardware.m
//  
//
//  Created by jijo on 26/02/10.
//  
//

#import "UIDeviceHardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_4_0 550.32
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_5_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_5_0 675.000000
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0 //50000

#define IF_IOS5_OR_GREATER(...) \
if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_5_0) \
{ \
__VA_ARGS__ \
}
#else
#define IF_IOS5_OR_GREATER(...)
#endif


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
#define IF_IOS4_OR_GREATER(...) \
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0) \
    { \
        __VA_ARGS__ \
    }
#else
#define IF_IOS4_OR_GREATER(...)
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
#define IF_3_2_OR_GREATER(...) \
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_3_2) \
    { \
        __VA_ARGS__ \
    }
#else 
#define IF_3_2_OR_GREATER(...)
#endif

NSInteger DeviceSystemMajorVersion(void);
NSInteger DeviceSystemMajorVersion() {
    static NSInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
    });
    return _deviceSystemMajorVersion;
}

#define ISIOS7 (DeviceSystemMajorVersion() >= 7)

#define ISIOS8 (DeviceSystemMajorVersion() >= 8)

@implementation UIDeviceHardware


+(BOOL) isOS8Device{
    
    return ISIOS8;
    
}

- (NSString *) platform{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithUTF8String:machine];
	free(machine);
	return platform;
}

//mod+20111011
- (NSString *) platformString{
	NSString *platform = [self platform];
	    
	if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])         return @"Simulator";
		//
	return platform;
}
+(BOOL) isIpad{
    
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    
}

+(BOOL) isOS4Device{

	IF_IOS4_OR_GREATER(
	
	   return YES;
	   	
	);
	return NO;
}
+(BOOL)isOS5Device {
    
    IF_IOS5_OR_GREATER(
        
        return YES;
    )
    return NO;
    /*
    NSString *osVersion = @"5.0";
    NSString *currOsVersion = [[UIDevice currentDevice] systemVersion];
    return [currOsVersion compare:osVersion options:NSNumericSearch] == NSOrderedAscending;*/
}
+(BOOL) isOS7Device {
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        return YES;
    }
    return NO;
}
+(BOOL) isOS6Device {
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        return YES;
    }
    return NO;
}
+(BOOL)isSupportRotation:(UIInterfaceOrientation)interfaceOrientation{
    
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    //if([self isiPad]) 
    //else return YES;
   
}
@end
