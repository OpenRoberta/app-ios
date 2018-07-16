#  Overview

this small app 

- creates a WKWebview which runs the OpenRoberta lab. The webview contains almost all logic to create and run programs for BlueTooth-enabled robots. Especially it contains an
  interpreter for a small stack machine, that executes the operations of the user program.
- contains logic to connect to LE BlueTooth devices
- is a mediator between the Javascript in the webview and the BlueTooth device
- if the device sends update signals for its sensor, they are propagated to the Javascript.
- if the interpreter gets operations for actuators of the robot (motor on/off, light to colour or off, play sounds on the piezo), they are propagated to the robot

The main design decision was, to keep the app small and robust. Changes should only be necessary for the (large) Java/Javascript part on the server and on the webview. Thus correcting errors
and adding functionality should NOT need a publish a new version of the app in the app store.

# MainViewController

creates the webview and loads the client code (Javascript) of the OpenRoberta lab into the webview. It contains a function called from the Javascript in the webview to process commands.
It enables alert/popup functionality for the webview.

# DeviceManager

it contains helper functions to convert dictionaries to JSON and sending JSON to Javascript in the webview. It starts and stops scanning for devices and stores the connected device.

# WeDoDevice

during the connection process it sends connect/disconnect calls to the BlueTooth device. In callbacks it gets the services exposed by the BlueTooth device one after the other.
Actuator services are remembered. For all services JSON-descriptions are sent to Javascript in the webview.  

Furthermore it contains a function, to send actuator commands to a connected device, and, it has callbacks to process update events from a connected device. The Javascript in the
webview gets these informations.

