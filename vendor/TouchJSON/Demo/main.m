#import <Foundation/Foundation.h>

#import "CJSONDeserializer.h"

void test(void);

int main(int argc, char **argv)
{
#pragma unused(argc, argv)

NSAutoreleasePool *theAutoreleasePool = [[NSAutoreleasePool alloc] init];

test();

[theAutoreleasePool release];
//
return(0);
}

void test(void)
{
NSString *theSource = NULL;
//
theSource = @"{\"r\":[{\"name\":\"KEXP\",\"desc\":\"90.3 - Where The Music Matters\",\"icon\":\"\\/img\\/channels\\/radio_stream.png\",\"audiostream\":\"http:\\/\\/kexp-mp3-1.cac.washington.edu:8000\\/\",\"type\":\"radio\",\"stream\":\"fb8155000526e0abb5f8d1e02c54cb83094cffae\",\"relay\":\"r2b\"}]}";
//theSource = @"[{\"a\":\"b\"}]";
//theSource = @"{\"status\": \"ok\", \"operation\": \"new_task\", \"task\": {\"status\": 0, \"updated_at\": {}, \"project_id\": 7179, \"dueDate\": null, \"creator_id\": 1, \"type_id\": 0, \"priority\": 1, \"id\": 37087, \"summary\": \"iPhone test\", \"description\": null, \"creationDate\": {}, \"owner_id\": 1, \"noteCount\": 0, \"commentCount\": 0}}";
//theSource = @"{\"status\": \"ok\", \"operation\": \"new_task\", \"task\": {\"status\": 0, \"project_id\": 7179, \"dueDate\": null, \"creator_id\": 1, \"type_id\": 0, \"priority\": 1, \"id\": 37087, \"summary\": \"iPhone test\", \"description\": null, \"owner_id\": 1, \"noteCount\": 0, \"commentCount\": 0}}";
//theSource = @"{ }";

NSUInteger theCount = 0;

NSAutoreleasePool *theAutoreleasePool = [[NSAutoreleasePool alloc] init];

for (int N = 0; N != 1000; ++N)
	{
	//
	NSData *theData = [theSource dataUsingEncoding:NSUTF32BigEndianStringEncoding];

	NSError *theError = NULL;
	id theObject = [[CJSONDeserializer deserializer] deserialize:theData error:&theError];
	theCount += [theObject count];
	theObject = NULL;
	//
	}

[theAutoreleasePool release];

//char theBuffer[256];
//fgets(theBuffer, 256, stdin);

NSLog(@"Result: %d", theCount);
}
