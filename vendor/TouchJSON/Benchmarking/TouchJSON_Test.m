#import "CJSONDeserializer.h"

NSDictionary *TouchJSONTest(NSData *theData)
{
NSDictionary *theOutput = [[CJSONDeserializer deserializer] deserialize:theData error:NULL];
return(theOutput);
}