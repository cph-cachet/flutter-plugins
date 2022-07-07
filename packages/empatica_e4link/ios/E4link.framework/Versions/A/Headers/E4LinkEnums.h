//
//  E4LinkEnums.m
//  E4link
//
//  Copyright © 2018 Empatica. All rights reserved.
//

/*!
 @enum          BLEStatus
 @abstract      Represents a status of the Bluetooth
 */
typedef enum {
    kBLEStatusNotAvailable,
    kBLEStatusReady,
    kBLEStatusScanning
} BLEStatus;

/*!
 @enum          DeviceStatus
 @abstract      Represents a status of the E4 device
 */
typedef enum {
    kDeviceStatusDisconnected,
    kDeviceStatusConnecting,
    kDeviceStatusConnected,
    kDeviceStatusFailedToConnect,
    kDeviceStatusDisconnecting
} DeviceStatus;

/*!
 @enum          SensorStatus
 @abstract      Represents whether the E4 device is on wrist or not
 */
typedef enum {
    kE2SensorStatusNotOnWrist,
    kE2SensorStatusOnWrist,
    kE2SensorStatusDead
} SensorStatus;
