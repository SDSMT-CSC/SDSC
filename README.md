iPhone Home Remote
========================

Formerly Smart Device System Control (2012-13)

The iPhone Home Remote is an end-to-end system for controlling devices over the internet using an iOS-enabled device, some custom hardware and a computer acting as a gateway host. This project was created to fullfil the Senior Design requirements for Fall 2012 and Spring 2013 at South Dakota School of Mines and Technology.

The system is currently capable of operating a garage door, and could theoretically be expanded with trivial difficulty to encompass a large range of devices which it is possible to query and activate through TCP/IP and Serial communication.

The systems involved here are an iPhone app for connection and control, a resolution server which is designed to keep track of base stations' dynamic IP addresses (so theoretically you could deploy it yourself to a place where IP or Domain is known) and a "Base Station" which acts as a router for devices.

The Base Station acts as a simple carrier, sending string or integer messages from any client capable of sending properly-formatted JSON data to serial devices or IP addresses.

You should think of this project as a "Proof-of-concept" or "Good start", rather than a complete solution for controlling your house. There are major security concerns: We're not using TLS at this point, so all data is in the clear, the base station doesn't authenticate those who connect to the web frontend, and the device protocols are not currently specified thoroughly, so some additional effort will be required to lock everything down and get permissions set correctly for everything. The Base Station also runs in the foreground, rather than as a daemon process, which should probably change if you want to use it seriously.

As of 25 April, 2013, the project is considered complete to class requirements. All of the code is handed over to L3 Communications and is their property.

The group working on this project consisted of Christopher Jensen, Joshua Kinkade, Brian Vogel and James Wiegand.
