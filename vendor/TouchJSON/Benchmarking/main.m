#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

extern NSDictionary *TouchJSONTest(NSData *theData);
extern NSDictionary *BSJSONTest(NSData *theData);
extern NSDictionary *SbrautasetJSONTest(NSData *theData);

typedef NSDictionary *(*testfuncptr)(NSData *theData);

int main (int argc, const char *argv[])
{
NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];

NSString *theFilename = [NSString stringWithUTF8String:argv[1]];
NSData *theContentData = [NSData dataWithContentsOfFile:theFilename];

NSString *theFunctionNames[] = { @"TouchJSON", @"Sbrautaset", @"BSJSON" };
testfuncptr theFunctions[] = { TouchJSONTest, SbrautasetJSONTest, BSJSONTest };

for (int N = 0; N != 2; ++N)
	{
	testfuncptr theTestPtr = theFunctions[N];
	NSLog(@"Library: %@", theFunctionNames[N]);
	int theCount = 1;

	UInt64 M0, M1;

	Microseconds((UnsignedWide *)&M0);

	for (int N = 0; N != theCount; ++N)
		{
		NSAutoreleasePool *theTestPool = [[NSAutoreleasePool alloc] init];

		NSDictionary *theOutput = (*theTestPtr)(theContentData);
	//	[theOutput retain];

		[theTestPool drain];

	//	[theOutput autorelease];
		}

	Microseconds((UnsignedWide *)&M1);
	NSLog(@"Microseconds: %g\n", ((double)(M1 - M0) / (double)theCount) / 1000000.0);
	}


[thePool drain];
return 0;
}