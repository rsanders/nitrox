#import <Foundation/Foundation.h>

#import "CJSONDeserializer.h"
#import "NSDictionary+BSJSONAdditions.h"

int main (int argc, const char * argv[])
{
NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];


NSString *theFilename = @"/Users/schwa/Desktop/d.json";
NSString *theContent = [NSString stringWithContentsOfFile:theFilename];
//id theData  = [[CJSONDeserializer deserializer] deserialize:theContent];
//NSLog(@"%d", [theData count]);


id theData = [NSDictionary dictionaryWithJSONString:theContent];
NSLog(@"%d", [theData count]);

[pool drain];
return 0;
}
