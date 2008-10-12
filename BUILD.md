

=== Preprocessor Symbols ===

These are C preprocessor symbols which you can define in your builds to influence 
the exact behavior of Nitrox.


== IPHONE_SDK_KOSHER ==

Only include functionality which is within the strictest interpretation of the
iPhone SDK Agreement.  This means that only documented methods of documented classes
are used.

== PERFORMANCE_TEST ==

Define this to maximize performance of Nitrox.  This includes turning off logging,
turning off Javascript tracing / debugging support, et cetera.  You should probably
enable this for release builds.

== TARGET_IPHONE_SIMULATOR ==

This is defined by Xcode so you shouldn't need to do so yourself.  This is used in cases
where the simulator differs from the actual HW, or when I expect some functionality to be
more useful on the simulator.  One example of that is auto-enabling Javascript debugging
on the simulator.

