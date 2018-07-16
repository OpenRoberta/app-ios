//
// Created by Søren Toft Odgaard on 25/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEService.h"


/**
 The SDK will create instances of this class for IOs with an unknown LEIOType.

 The LEGenericService is a 'tagging' interface and does not offer any extra methods or properties other than those available
 from its parent class LEService.

 As opposed to the known service types (tilt, motion, etc) a generic service does not have a predefined [LEService defaultInputFormat].
 Therefore, when the SDK discovers a service with a type it does not recognize it does not automatically send an LEInputFormat
 to the LEDevice. Without a configured input format the Device will not send any updates for the SDK when the value readings of the sensor
 value changes for that service.

  To receive IO value reading updates you must create and send an LEInputFormat to the device to be used for the service. You may look for
 inspiration on how to do this in one of the concrete service classes, like the LEMotionSensor or LEVoltageSensor. Below an example
 is given on how you could configure and use a new Temperature Sensor yet unknown to the SDK.

     if ([service isKindOfClass:[LEGenericService class]] &&
             service.connectInfo.type == temperatureSensorTypeNumber) {

         LEGenericService *temperatureSensor = (LEGenericService *) service;

         //The temperature sensor is yet unknown to the SDK (there is no
         //LETemperatureSensor class) so we need to configure
         //the service ourselves.

         //As a generic sensor does not how a defaultInputFormat is defined
         //we must create one and send it to the device.
         //Look in the documentation for the temperature sensor to see which modes it supports.
         LEInputFormat *inputFormat = [LEInputFormat
                 inputFormatWithConnectID:service.connectInfo.connectID
                 typeID:service.connectInfo.type
                 mode:0 //See the documentation for the sensor for supported modes
                 deltaInterval:1 //Receive updates when the value changes with delta 1
                 unit:LEInputFormatUnitSI
                 notificationsEnabled:YES];

         //Tell the device to configure the sensor with the input format
         [temperatureSensor updateInputFormat:inputFormat];


         //We know from the documentation that the temperature sensor produces readings in
         //Kelvin as 4 byte floats when in mode 0 with unit set to SI.
         LEDataFormat *dataFormat = [LEDataFormat
                 formatWithModeName:@"Kelvin"
                 mode:0 //must match the mode for the inputFormat
                 unit:LEInputFormatUnitSI //must match the unit for the inputFormat
                 sizeOfDataSet:4 //a 4 byte float
                 dataSetCount:1]; //only one value in the data set (the temperature)

         [temperatureSensor addValidDataFormat:dataFormat];

         //Now, add a delegate to receive notifications when the service has a new
         //temperature reading
         [temperatureSensor addDelegate:self];
     }


Now, when the service receives an updated value from the temperature sensor you will receive
a notification through the delegate.

    - (void)service:(LEService *)service didUpdateValueDataFrom:(NSData *)oldValue to:(NSData *)newValue
    {
        //As we have defined a valid data format stating that the received value can be parsed as a 4 byte
        //float we can use the convenience method to retrieve the value as a float.
        Float32 temperatureReading = service.valueAsFloat;

    }

It is not required to add a valid data format to the LEGenericService, but it is recommended to
do so as this will also help the SDK validate all received data according to the defined valid data formats
and write any inconsistencies to the LELogger.


*/
@interface LEGenericService : LEService
@end