Nitrox - an iPhone HTML/JS Application Environment
==================================================

For all the divers in the house...what's better than AIR?  NITROX!

A Cocoa/Objective-C wrapper for Javascript applications on the iPhone
which provides access to native iPhone functions.

See http://code.google.com/p/nitrox for more information.

How to Use Nitrox
=================

Nitrox is not a browser.  It is intended to be used as a library and wrapper for iPhone
applications written with HTML and Javascript.

The underlying mechanism is the iPhone UIKit's UIWebView.  As of iPhone SDK 2.1, most of
the device-specific functionality of the iPhone is not exposed to Javascript programs.  The
goal of Nitrox is to make that functionality available.

To create a Nitrox application, you should create a new Cocoa Touch application in Xcode just 
as you would for a pure Objective-C application.  Then you will follow the steps described
in INSTALL.md to make Nitrox available to your main application.

In addition, you will include a "web" directory with the application which contains your
HTML and Javascript files.

You can extend Nitrox with your own Objective-C functions.  You do not need to use Nitrox
for your entire application.  You can use it for only certain views or functions, and use
pure Objective-C for others.  


Similar systems
---------------

Phonegap (http://www.phonegap.com/) is the most similar.  The main difference between
Phonegap and Nitrox is that Nitrox uses a local XMLHTTPRequest/Ajax connection to 
invoke Objective-C from Javascript. 

See http://code.google.com/p/nitrox/wiki/Performance for a comparison and performance
analysis.


Source Code
============

You can grab source code from Github at the following URL:

     http://github.com/rsanders/nitrox/tree/master


Release Notes
=============

v0.2 - 2008-10-06
------------------

Working:

* Ajax-based invocation of functions (slower but more reliable and optionally
  synchronous)
* Accelerometer
* Location functions
* Vibrate function
* System functions including exiting and openURL
* UIDevice property access
* Loading of Javascript files accessible via XMLHTTPRequest
* Simple (explicit, not automatic) proxying of GET requests for non-local URLs...
  could be used in some places where XMLHTTPRequest is used.
* Logging
* General Notification subscription and sending
* Callbacks to JS for accel, location, orientation, notifications

Testing:

* Faster but less general syscall method using UIWebView delegate interception
  rather than Ajax / HTTP
* Much faster and more general and more powerful method using WebKit native Obj-C
  bridge; not currently formally supported and probably App Store poison. (works, though)


