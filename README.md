Nitrox

A Cocoa/Objective-C wrapper for Javascript applications on the iPhone
which provides access to native iPhone functions.

See http://code.google.com/p/nitrox for more information.

Working in v0.2 - 2008-10-06:

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


