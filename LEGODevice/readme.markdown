The LEGO Device SDK is used communicate with various LEGO manufactured hardware such as sensors and motors.

Currently the library supports only communication with hardware connected through Bluetooth LE (BLE). The SDK will help
you scan for and connect to LEGO BLE devices. Once connected to a device the SDK will provide access to read and be notified about changes to sensor values,
 and to send commands to various outputs (motors, piezo-tone, etc.)


Scanning for and Connecting to Advertising Devices
--------------------------------------------------

To scan for nearby advertising devices you use the LEDeviceManager as illustrated in the example below.

	- (void)startScanningForDevices
	{
		[[LEDeviceManager sharedConnectionManager] addDelegate:self];
		[[LEDeviceManager sharedConnectionManager] scan];
	}

	#pragma mark - LEDeviceManagerDelegate
	- (void)deviceManager:(LEDeviceManager *)manager deviceDidAppear:(LEDevice *)device
	{
		NSLog(@"Did discover device %@", device.name);
	}


The LEDeviceManagerDelegate will inform you whenever a new device starts or stop advertising. After a device has been discovered you can connect to it.
Again the LEDeviceManagerDelegate will notify you once the connection is established (or if the connection fails).
Before connecting to a device you should add a LEDeviceDelegate to the device.
Through this delegate you will be notified on any services (motors, sensors, etc.) offered by the device.

	- (void)connectToDevice:(LEDevice *)device
	{
	    [device addDelegate:self];
	    [[LEDeviceManager sharedConnectionManager] connectToDevice:device];
	}

	#pragma mark - LEDeviceManagerDelegate
	- (void)deviceManager:(LEDeviceManager *)manager didFinishInterrogatingDevice:(LEDevice *)device
	{
	    NSLog(@"Did successfully connect to device: %@", device);
	}

	#pragma mark - LEDeviceDelegate
	- (void)device:(LEDevice *)device didAddService:(LEService *)service
	{
	    NSLog(@"Device did add service: %@", service.serviceName);
	}


Read Values From a Known Input connected to the Device
-----------------------------------------------

Once connected to a LEDevice, and having discovered one or more services you are ready to start read info from sensors and send commands to motors and other outputs.
For example, to start listening to updates from a tilt sensor:

	- (void)startUsingService:(LEService *)service
	{
	    if ([service isKindOfClass:[LETiltSensor class]]) {
	        LETiltSensor *tiltSensor = (LETiltSensor *) service;
	        [tiltSensor addDelegate:self];
	    }
	}

	#pragma mark - LETiltSensorDelegate
	- (void)tiltSensor:(LETiltSensor *)sensor didUpdateAngleFrom:(LETiltSensorAngle)oldAngle to:(LETiltSensorAngle)newAngle
	{
	    NSLog(@"Tilt sensor changed angle to %f, %f", newAngle.x, newAngle.y);
	}


Communicate with a Generic Input connected to the Device
---------------------------------------------------------

If a service is an instance of the class LEGenericService this means that the IO type in unkown to the SDK.
As opposed to the known service types (tilt, motion, etc) a generic service does not have a predefined [LEService defaultInputFormat]
and therefore an LEInputFormat is not automatically send to the LEDevice. This means that per default no data is send from the
device to the SDK when the IO reads a new data value. To use a LEGenericService to receive data updated from a sensor unkown to the SDK you
must create and send an LEInputFormat to the device. Find inspiration in one of the concrete service classes for this, like the LEMotionSensor
or LEVoltageSensor.

Also see the documentation of the LEGenericService class for an example on how to configure and use an IO unkown to the SDK.


Getting Debug and Error log from the LEGO Device SDK
----------------------------------------------------

You should insert the following code snippet in your AppDelegate application:didFinishLaunchingWithOptions method.

    #ifdef DEBUG
        [LELogger defaultLogger].logLevel = LELoggerLevelDebug;
    #else
        [LELogger defaultLogger].logLevel = LELoggerLevelWarn;
    #endif

It is also possible to redirect the LEDevice log statement to another destination, for example an online logging
service or a (debug) text view in your app. You can do this by creating a class that implements the LELogWriter protocol
and set the [LELogger logWriter] property.


