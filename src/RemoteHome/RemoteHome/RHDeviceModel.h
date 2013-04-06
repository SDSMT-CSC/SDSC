//
//  RHDeviceModel.h
//  RemoteHome
//
//  Created by James Wiegand on 1/8/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import <Foundation/Foundation.h>

enum RHDeviceType {
    RHGarageDoorType = 1,
    RHSprinklerType = 2,
    RHLightType = 3
    };

enum RHErrorCodes {
    RHErrorNoError = 0,
    RHErrorOffline = 1
    };

@interface RHDeviceModel : NSObject

@property (nonatomic, retain)   NSString* deviceName;
@property (nonatomic, retain)   NSString* deviceSerial;
@property (nonatomic)           enum RHDeviceType deviceType;
@property (nonatomic)           NSUInteger errorCode;



@end
