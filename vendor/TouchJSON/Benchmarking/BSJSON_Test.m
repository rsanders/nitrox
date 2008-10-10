#import "NSDictionary+BSJSONAdditions.h"

NSDictionary *BSJSONTest(NSData *theData)
{
NSString *theContentString = [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] autorelease];
NSDictionary *theOutput = [NSDictionary dictionaryWithJSONString:theContentString];
return(theOutput);
}