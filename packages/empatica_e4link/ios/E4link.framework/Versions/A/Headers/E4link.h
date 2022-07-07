//
//  E4link.h
//  E4link
//
//  Copyright © 2018 Empatica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//! Project version number for E4link.
FOUNDATION_EXPORT double E4linkVersionNumber;

//! Project version string for E4link.
FOUNDATION_EXPORT const unsigned char E4linkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <E4link/PublicHeader.h>

#import "E4LinkEnums.h"


@class EmpaticaDevice, EmpaticaDeviceManager;


/*!
 @protocol      EmpaticaDelegate
 @abstract      This protocol should be implemented to be notified when E4 devices are discovered nearby.
 @discussion    The methods on this protocol are called on an internal queue. Call the main thread to update the user interface.
 */
@protocol EmpaticaDelegate<NSObject>

- (void)didUpdateBLEStatus:(BLEStatus)status;

- (void)didDiscoverDevices:(NSArray *)devices;

@end

/*!
 @protocol      EmpaticaDeviceDelegate
 @abstract      This protocol should be implemented to be notified when a E4 device status changes, receive battery updates and streams signals values.
 @discussion    The methods on this protocol are called on an internal queue. Call the main thread to update the user interface.
 */
@protocol EmpaticaDeviceDelegate<NSObject>

@optional

- (void)didReceiveGSR:(float)gsr withTimestamp:(double)timestamp fromDevice:(EmpaticaDeviceManager *)device;

- (void)didReceiveBVP:(float)bvp withTimestamp:(double)timestamp fromDevice:(EmpaticaDeviceManager *)device;

- (void)didReceiveTemperature:(float)temp withTimestamp:(double)timestamp fromDevice:(EmpaticaDeviceManager *)device;

- (void)didReceiveAccelerationX:(char)x y:(char)y z:(char)z withTimestamp:(double)timestamp fromDevice:(EmpaticaDeviceManager *)device;

- (void)didReceiveIBI:(float)ibi withTimestamp:(double)timestamp fromDevice:(EmpaticaDeviceManager *)device;

- (void)didReceiveBatteryLevel:(float)level withTimestamp:(double)timestamp fromDevice:(EmpaticaDeviceManager *)device;

- (void)didReceiveTagAtTimestamp:(double)timestamp fromDevice:(EmpaticaDeviceManager *)device;

- (void)didUpdateDeviceStatus:(DeviceStatus)status forDevice:(EmpaticaDeviceManager *)device;

- (void)didUpdateOnWristStatus:(SensorStatus)onWristStatus forDevice:(EmpaticaDeviceManager*)device;;

@end

/*!
 @class          EmpaticaAPI
 @abstract       The EmpaticaAPI class provides an interface for discovering E4 devices.
 */
@interface EmpaticaAPI : NSObject


+ (void)authenticateWithAPIKey:(NSString *)apiKey andCompletionHandler:(void (^)(BOOL success, NSString * description))handler;

+ (void)discoverDevicesWithDelegate:(id<EmpaticaDelegate>)empaticaDelegate;

+ (void)cancelDiscovery;

+ (void)prepareForBackground;

+ (void)prepareForResume;


+ (BLEStatus)status;


@end


/*!
 @class          EmpaticaDeviceManager
 @abstract       The EmpaticaDeviceManager class provides an interface for connecting to a E4 device.
 @discussion     The EmpaticaDeviceManager class represents a single discovered E4 device. Use this class to connect and keeping a reference to the connected device.
 */
@interface EmpaticaDeviceManager : NSObject


@property (nonatomic, copy, readonly) NSString * name;

@property (nonatomic, copy, readonly) NSString * serialNumber;

@property (nonatomic, copy, readonly) NSString * advertisingName;

@property (nonatomic, copy, readonly) NSString * hardwareId;

@property (nonatomic, copy, readonly) NSString * firmwareVersion;


@property (nonatomic, assign, readonly) BOOL allowed;

@property (nonatomic, assign, readonly) BOOL isFaulty;


@property (nonatomic, assign, readonly) DeviceStatus deviceStatus;


- (void)connectWithDeviceDelegate:(id<EmpaticaDeviceDelegate>)deviceDelegate;

- (void)connectWithDeviceDelegate:(id<EmpaticaDeviceDelegate>)deviceDelegate andConnectionOptions:(NSArray *)connectionOptions;

/*!
 @method     disconnect
 @abstract   Cancel an active connection to the E4 device.
 */
- (void)disconnect;

/*!
 @method     cancelConnection
 @abstract   Cancel a pending connection to the E4 device.
 */
- (void)cancelConnection;

@end
