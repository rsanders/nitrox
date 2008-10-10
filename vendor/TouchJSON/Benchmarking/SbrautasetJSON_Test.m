#import "NSString+SBJSON.h"

NSDictionary *SbrautasetJSONTest(NSData *theData)
{
NSString *theContentString = [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] autorelease];
NSDictionary *theOutput = [theContentString JSONValue];
return(theOutput);
}