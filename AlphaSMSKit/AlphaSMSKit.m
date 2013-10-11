//
//  AlphaSMSKit.m
//  AlphaSMSKit
//
//  Created by Xenon on 10/10/13.
//
//

#import "AlphaSMSKit.h"
#import "AlphaSMSMessage.h"
#import "AlphaSMSMessageStatus.h"
#import <XMLDictionary.h>
#import <AFNetworking/AFNetworking.h>

#define ALPHASMS_API_BASEURL    @"https://alphasms.com.ua"      //AlphaSMS base URL for API calls
#define ALPHASMS_API_PATH       @"/api/xml.php"                 //AlphaSMS URL path for API calls

#define XML_HEADER_STRING       @"<?xml version=\"1.0\" encoding=\"utf-8\" ?>"

static NSString *_secretKey;

@implementation AlphaSMSKit

+ (void)setSecretKey:(NSString *)secretKey
{
    _secretKey = secretKey;
}

+ (AlphaSMSServiceError)errorCodeFromInteger:(NSInteger)intCode
{
    switch (intCode) {
        case AlphaSMSServiceErrorUnknown:       return AlphaSMSServiceErrorUnknown;
        case AlphaSMSServiceErrorFormat:        return AlphaSMSServiceErrorFormat;
        case AlphaSMSServiceErrorAuth:          return AlphaSMSServiceErrorAuth;
        case AlphaSMSServiceErrorAPIDisabled:   return AlphaSMSServiceErrorAPIDisabled;
        case AlphaSMSServiceErrorIPDenied:      return AlphaSMSServiceErrorIPDenied;
            
        default: return AlphaSMSServiceErrorInvalid;
    }
}

- (void)callAPIWithXML:(NSString *)xml
               success:(void (^)(NSDictionary *responseDictionary))success
               failure:(void (^)(NSError *error))failure
{
    NSURL *baseUrl = [NSURL URLWithString:ALPHASMS_API_BASEURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ALPHASMS_API_PATH relativeToURL:baseUrl]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    
    //generate an NSData from XML string
    NSData *body = [xml dataUsingEncoding:NSUTF8StringEncoding];
    
    //set method and body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    
    //add "Content-Length" header
    //unsigned long long postLength = body.length;
    //[request addValue:[NSString stringWithFormat:@"%llu", postLength] forHTTPHeaderField:@"Content-Length"];
    
    AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //fetch response as string
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"Request Successful, response '%@'", responseString);
        
        //parse XML response into dictionary
        [[XMLDictionaryParser sharedInstance] setAlwaysUseArrays:YES];
        NSDictionary *responseDictionary = [NSDictionary dictionaryWithXMLString:responseString];
        //trigger success block
        success(responseDictionary);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //trigger failure
        NSLog(@"HTTP error: %@", error.localizedDescription);
        failure(error);
    }];
    
    [httpClient enqueueHTTPRequestOperation:operation];
}


- (void)sendMessages:(NSArray *)messages
             success:(void (^)(NSArray *messageStatuses))success
             failure:(void (^)(NSError *error))failure
{
    //build nodes for request XML
    //add <package key="[secretKey]"> root node
    // __name - internal XMLDictionary key for setting XML node name
    NSMutableDictionary *nodes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"package", @"__name",
                                  _secretKey, @"_key", nil];
    
    //need to build array of elements ready to be converted to XML with XMLDictionary later
    NSMutableArray *preparedMessages = [NSMutableArray array];
    for (AlphaSMSMessage *message in messages) {
        //add mandatory message parameters
        // __text - internal XMLDictionary key for setting XML node text
        // other keys - are for setting XML node attributes required by AlphaSMS XML request format
        NSMutableDictionary *preparedMessage = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                message.text, @"__text",
                                                message.recipient, @"_recipient",
                                                message.sender, @"_sender",
                                                [NSString stringWithFormat:@"%d", message.type], @"_type",
                                                nil];
        //add optional parameters if needed
        if (message.messageId) [preparedMessages setValue:message.messageId forKey:@"_id"];
        if (message.scheduleDate) [preparedMessages setValue:message.scheduleDate forKey:@"_date_beg"]; //convert date to str
        if (message.expirationDate) [preparedMessages setValue:message.expirationDate forKey:@"_date_end"]; //convert date to str
        if (message.wapURL) [preparedMessages setValue:message.wapURL forKey:@"_url"];
        
        //put prepared message to the list
        [preparedMessages addObject:@{@"msg":preparedMessage}];
    }
    
    //[nodes setObject:@[ @{@"msg":@{@"_id":@"1", @"_sms_id":@"123", @"__text":@"MSG TEXTO 1"} }, @{@"msg":@{@"_id":@"2", @"__text":@"MSG TEXTO 2"}}] forKey:@"message"];
    [nodes setObject:preparedMessages forKey:@"message"];
    
    NSLog(@"XML to post: %@", [NSString stringWithFormat:@"%@%@", XML_HEADER_STRING, [nodes XMLString]]);
    
    //call API
    [self callAPIWithXML:[nodes XMLString] success:^(NSDictionary *responseDictionary) {
        
        //NSLog(@"Got response: %@", responseDictionary);
        
        //check for error node
        if ([responseDictionary valueForKeyPath:@"error"]) {
            NSString *errorCodeString = [responseDictionary valueForKeyPath:@"error"][0];
            AlphaSMSServiceError errorCode = [AlphaSMSKit errorCodeFromInteger:[errorCodeString integerValue]];
            //NSLog(@"Service error code: %d", errorCode);
            
            //trigger failure
            failure ([NSError errorWithDomain:@"AlphaSMSKit" code:errorCode userInfo:nil]);
        }
        
        //no error node - parse response nodes
        else {
            NSArray *messageStatusNodes = [responseDictionary valueForKeyPath:@"message.msg"];
            //NSLog(@"Array: %@", messageStatusNodes);
            
            NSMutableArray *messageStatuses = [NSMutableArray array];
            for (NSDictionary *messageStatusNode in messageStatusNodes[0]) {
                
                NSString *messageCode = [messageStatusNode valueForKey:@"__text"];
                NSString *messageId = [messageStatusNode valueForKey:@"_id"];
                NSString *messageSmsId = [messageStatusNode valueForKey:@"_sms_id"];
                NSString *messageSmsCount = [messageStatusNode valueForKey:@"_sms_count"];
                AlphaSMSMessageStatusCode statusCode = [AlphaSMSMessageStatus statusCodeFromInteger:[messageCode integerValue]];
                
                AlphaSMSMessageStatus *messageStatus = [[AlphaSMSMessageStatus alloc] initMessageStatusWithCode:statusCode
                                                                                                      messageId:[NSNumber numberWithInteger:[messageId integerValue]]
                                                                                               gatewayMessageId:[NSNumber numberWithInteger:[messageSmsId integerValue]]
                                                                                                       smsCount:[NSNumber numberWithInteger:[messageSmsCount integerValue]]
                                                                                                 completionDate:nil];
                [messageStatuses addObject:messageStatus];
            }
            
            //trigger success block
            success(messageStatuses);
        }
        
    } failure:^(NSError *error) {
        //trigger failure
        failure (error);
    }];
}


#pragma mark - Utilities

-(NSString *) strFromISO8601:(NSDate *) date {
    static NSDateFormatter* sISO8601 = nil;
    
    if (!sISO8601) {
        sISO8601 = [[NSDateFormatter alloc] init];
        
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        int offset = [timeZone secondsFromGMT];
        
        NSMutableString *strFormat = [NSMutableString stringWithString:@"yyyyMMdd'T'HH:mm:ss"];
        offset /= 60; //bring down to minutes
        if (offset == 0)
            [strFormat appendString:@"Z"];
        else
            [strFormat appendFormat:@"%+02d%02d", offset / 60, offset % 60];
        
        [sISO8601 setTimeStyle:NSDateFormatterFullStyle];
        [sISO8601 setDateFormat:strFormat];
    }
    return[sISO8601 stringFromDate:date];
}

-(NSDate *) dateFromISO8601:(NSString *) str {
    static NSDateFormatter* sISO8601 = nil;
    
    if (!sISO8601) {
        sISO8601 = [[NSDateFormatter alloc] init];
        [sISO8601 setTimeStyle:NSDateFormatterFullStyle];
        [sISO8601 setDateFormat:@"yyyyMMdd'T'HH:mm:ss"];
    }
    if ([str hasSuffix:@"Z"]) {
        str = [str substringToIndex:(str.length-1)];
    }
    
    NSDate *d = [sISO8601 dateFromString:str];
    return d;
    
}

@end
