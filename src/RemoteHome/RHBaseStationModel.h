//
//  RHBaseStationModel.h
//  RemoteHome
//
//  Created by James Wiegand on 11/29/12.
//  Copyright (c) 2012 James Wiegand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CommonCrypto/CommonCrypto.h>

@interface RHBaseStationModel : NSManagedObject

@property (nonatomic, retain) NSString * commonName;
@property (nonatomic, retain) NSString * hashedPassword;
@property (nonatomic, retain) NSString * ipAddress;
@property (nonatomic, retain) NSString * serialNumber;

- (void)setPasswordWithoutHash:(NSString*)password;

@end
