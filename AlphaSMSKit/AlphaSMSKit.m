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
#define ALPHASMS_ERROR_DOMAIN   @"AlphaSMSKit"

static NSString *_secretKey;

@implementation AlphaSMSKit

+ (AlphaSMSKit *)sharedKit
{
    static dispatch_once_t once;
    static AlphaSMSKit *sharedKit;
    dispatch_once(&once, ^ {
        sharedKit = [[AlphaSMSKit alloc] init];
    });
    return sharedKit;
}

// set your customer secret key
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

#pragma mark - Public API methods

// attempt to send messages
// (NSArray *)messages: array of AlphaSMSMessage objects
+ (void)sendMessages:(NSArray *)messages
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
        if (message.messageId) [preparedMessage setValue:[message.messageId stringValue] forKey:@"_id"];
        if (message.scheduleDate) [preparedMessage setValue:[[AlphaSMSKit sharedKit] stringISO8601FromDate:message.scheduleDate] forKey:@"_date_beg"];
        if (message.expirationDate) [preparedMessage setValue:[[AlphaSMSKit sharedKit] stringISO8601FromDate:message.expirationDate] forKey:@"_date_end"];
        if (message.wapURL) [preparedMessage setValue:message.wapURL forKey:@"_url"];
        
        //put prepared message to the list
        [preparedMessages addObject:@{@"msg":preparedMessage}];
    }
    [nodes setObject:preparedMessages forKey:@"message"];
    
    //call API for getting 'message' results
    [[AlphaSMSKit sharedKit] callAPIAndGetMessageStatusesWithXML:[XML_HEADER_STRING stringByAppendingString:[nodes XMLString]]
                                                     forNodeName:@"message"
                                                         success:^(NSArray *messageStatuses) {
                                                             //trigger success block
                                                             success(messageStatuses);
                                                         } failure:^(NSError *error) {
                                                             //trigger failure
                                                             failure (error);
                                                         }];
}

// attempt to get message statuses
// (NSArray *)messageRequests: array of AlphaSMSMessageStatusRequest objects
+ (void)getMessageStatuses:(NSArray *)messageRequests
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
    NSMutableArray *preparedMessageRequests = [NSMutableArray array];
    for (AlphaSMSMessageStatusRequest *messageRequest in messageRequests) {
        //add mandatory message parameters
        // __text - internal XMLDictionary key for setting XML node text
        // other keys - are for setting XML node attributes required by AlphaSMS XML request format
        NSMutableDictionary *preparedMessageRequest = [NSMutableDictionary dictionary];
        
        //add parameters if needed
        if (messageRequest.messageId) [preparedMessageRequest setValue:[messageRequest.messageId stringValue] forKey:@"_id"];
        if (messageRequest.gatewayMessageId) [preparedMessageRequest setValue:[messageRequest.gatewayMessageId stringValue] forKey:@"_sms_id"];
        
        //put prepared message status request to the list
        [preparedMessageRequests addObject:@{@"msg":preparedMessageRequest}];
    }
    [nodes setObject:preparedMessageRequests forKey:@"status"];
    
    //call API for getting 'status' results
    [[AlphaSMSKit sharedKit] callAPIAndGetMessageStatusesWithXML:[XML_HEADER_STRING stringByAppendingString:[nodes XMLString]]
                                                     forNodeName:@"status"
                                                         success:^(NSArray *messageStatuses) {
                                                             //trigger success block
                                                             success(messageStatuses);
                                                         } failure:^(NSError *error) {
                                                             //trigger failure
                                                             failure (error);
                                                         }];
}

// attempt to delete messages (if they are not yet sent to operator)
// (NSArray *)messageRequests: array of AlphaSMSMessageStatusRequest objects
+ (void)deleteMessages:(NSArray *)messageRequests
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
    NSMutableArray *preparedMessageRequests = [NSMutableArray array];
    for (AlphaSMSMessageStatusRequest *messageRequest in messageRequests) {
        //add mandatory message parameters
        // __text - internal XMLDictionary key for setting XML node text
        // other keys - are for setting XML node attributes required by AlphaSMS XML request format
        NSMutableDictionary *preparedMessageRequest = [NSMutableDictionary dictionary];
        
        //add parameters if needed
        if (messageRequest.messageId) [preparedMessageRequest setValue:[messageRequest.messageId stringValue] forKey:@"_id"];
        if (messageRequest.gatewayMessageId) [preparedMessageRequest setValue:[messageRequest.gatewayMessageId stringValue] forKey:@"_sms_id"];
        
        //put prepared message status request to the list
        [preparedMessageRequests addObject:@{@"msg":preparedMessageRequest}];
    }
    [nodes setObject:preparedMessageRequests forKey:@"delete"];
    
    //call API for getting 'status' results
    [[AlphaSMSKit sharedKit] callAPIAndGetMessageStatusesWithXML:[XML_HEADER_STRING stringByAppendingString:[nodes XMLString]]
                                                     forNodeName:@"status"
                                                         success:^(NSArray *messageStatuses) {
                                                             //trigger success block
                                                             success(messageStatuses);
                                                         } failure:^(NSError *error) {
                                                             //trigger failure
                                                             failure (error);
                                                         }];
}

// get user balance
+ (void)getBalanceWithSuccess:(void (^)(NSNumber *amount, NSString *currency))success
                      failure:(void (^)(NSError *error))failure
{
    //build nodes for request XML
    //add <package key="[secretKey]"> root node
    // __name - internal XMLDictionary key for setting XML node name
    NSMutableDictionary *nodes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"package", @"__name",
                                  _secretKey, @"_key", nil];
    
    //add empty <balance/> node
    [nodes setObject:@"" forKey:@"balance"];
    
    //call API and then parse response XML into balance status object, checking for errors before
    [[AlphaSMSKit sharedKit] callAPIWithXML:[XML_HEADER_STRING stringByAppendingString:[nodes XMLString]]
                                    success:^(NSDictionary *responseDictionary) {
        
                                        //check for error node
                                        if ([responseDictionary valueForKeyPath:@"error"]) {
                                            NSString *errorCodeString = [responseDictionary valueForKeyPath:@"error"][0];
                                            AlphaSMSServiceError errorCode = [AlphaSMSKit errorCodeFromInteger:[errorCodeString integerValue]];
                                            
                                            //trigger failure
                                            failure ([NSError errorWithDomain:ALPHASMS_ERROR_DOMAIN code:errorCode userInfo:nil]);
                                        }
                                        
                                        //no error node - parse response nodes
                                        else {
                                            NSNumber *amount = [responseDictionary valueForKeyPath:@"balance.amount"][0][0];
                                            NSString *currency = [responseDictionary valueForKeyPath:@"balance.currency"][0][0];
                                            
                                            //trigger success block
                                            success(amount, currency);
                                        }
                                        
                                    } failure:^(NSError *error) {
                                        //trigger failure
                                        failure (error);
                                    }];
}

#pragma mark - Internal methods

//wrapper for callAPIWithXML:success:failure: - parse response XML using given root node name, also check for response errors
- (void)callAPIAndGetMessageStatusesWithXML:(NSString *)xml
                                forNodeName:(NSString *)nodeName
                                    success:(void (^)(NSArray *messageStatuses))success
                                    failure:(void (^)(NSError *error))failure
{
    //call API and then parse response XML into message status objects, checking for errors before
    [self callAPIWithXML:xml success:^(NSDictionary *responseDictionary) {
        
        //check for error node
        if ([responseDictionary valueForKeyPath:@"error"]) {
            NSString *errorCodeString = [responseDictionary valueForKeyPath:@"error"][0];
            AlphaSMSServiceError errorCode = [AlphaSMSKit errorCodeFromInteger:[errorCodeString integerValue]];
            
            //trigger failure
            failure ([NSError errorWithDomain:ALPHASMS_ERROR_DOMAIN code:errorCode userInfo:nil]);
        }
        
        //no error node - parse response nodes
        else {
            NSArray *messageStatusNodes = [responseDictionary valueForKeyPath:[NSString stringWithFormat:@"%@.msg", nodeName]];
            
            NSMutableArray *messageStatuses = [NSMutableArray array];
            for (NSDictionary *messageStatusNode in messageStatusNodes[0]) {
                
                NSString *messageId = [messageStatusNode valueForKey:@"_id"];
                NSString *messageSmsId = [messageStatusNode valueForKey:@"_sms_id"];
                NSString *messageSmsCount = [messageStatusNode valueForKey:@"_sms_count"];
                NSString *messageCompletedDate = [messageStatusNode valueForKey:@"_date_completed"];
                NSString *messageCode = [messageStatusNode valueForKey:@"__text"];
                AlphaSMSMessageStatusCode statusCode = [AlphaSMSMessageStatus statusCodeFromInteger:[messageCode integerValue]];
                
                AlphaSMSMessageStatus *messageStatus = [AlphaSMSMessageStatus messageStatusWithCode:statusCode
                                                                                          messageId:[NSNumber numberWithInteger:[messageId integerValue]]
                                                                                   gatewayMessageId:[NSNumber numberWithInteger:[messageSmsId integerValue]]
                                                                                           smsCount:[NSNumber numberWithInteger:[messageSmsCount integerValue]]
                                                                                     completionDate:(messageCompletedDate ? [self dateFromStringISO8601:messageCompletedDate] : nil)];
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

//common API call
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


#pragma mark - Utilities

- (NSString *)stringISO8601FromDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        
        int offset = [[NSTimeZone localTimeZone] secondsFromGMT] / 60; //bring down to minutes
        NSString *strFormat = (offset != 0 ? [NSString stringWithFormat:@"yyyy-MM-dd'T'HH:mm:ss+%02d:%02d", offset / 60, offset % 60] : @"yyyy-MM-dd'T'HH:mm:ssZ");
        
        [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
        [dateFormatter setDateFormat:strFormat];
    }
    return[dateFormatter stringFromDate:date];
}

- (NSDate *)dateFromStringISO8601:(NSString *)string
{
    static NSDateFormatter *dateFormatter = nil;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    }
    return [dateFormatter dateFromString:string];
}

@end
