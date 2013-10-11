//
//  AlphaSMSMessage.m
//  AlphaSMSKit
//
//  Created by Xenon on 10/10/13.
//
//

#import "AlphaSMSMessage.h"

@implementation AlphaSMSMessage

//common message setup
+ (AlphaSMSMessage *)messageWithText:(NSString *)text
                                type:(AlphaSMSMessageType)type
                           recipient:(NSString *)recipient
                              sender:(NSString *)sender
                        scheduleDate:(NSDate *)scheduleDate
                      expirationDate:(NSDate *)expirationDate
                              wapURL:(NSString *)wapURL
{
    AlphaSMSMessage *message = [[super alloc] init];
    message.messageId = nil; //we don't want to sent message id explicitly
    message.type = type;
    message.recipient = recipient;
    message.sender = sender;
    message.text = text;
    message.scheduleDate = scheduleDate;
    message.expirationDate = expirationDate;
    message.wapURL = wapURL;
    return message;
}

//setup message for sending at given date with given expiration period
+ (AlphaSMSMessage *)messageWithText:(NSString *)text
                                type:(AlphaSMSMessageType)type
                           recipient:(NSString *)recipient
                              sender:(NSString *)sender
                        scheduleDate:(NSDate *)scheduleDate
                      expirationDate:(NSDate *)expirationDate
{
    return [AlphaSMSMessage messageWithText:text type:type recipient:recipient sender:sender scheduleDate:scheduleDate expirationDate:expirationDate wapURL:nil];
}

//setup message for sending immediately with default expiration date (1 day)
+ (AlphaSMSMessage *)messageWithText:(NSString *)text
                                type:(AlphaSMSMessageType)type
                           recipient:(NSString *)recipient
                              sender:(NSString *)sender
{
    return [AlphaSMSMessage messageWithText:text type:type recipient:recipient sender:sender scheduleDate:nil expirationDate:nil wapURL:nil];
}

// setup wap-push message for sending immediately with default expiration date (1 day)
+ (AlphaSMSMessage *)wapMessageWithText:(NSString *)text
                                 wapURL:(NSString *)wapURL
                              recipient:(NSString *)recipient
                                 sender:(NSString *)sender
{
    return [AlphaSMSMessage messageWithText:text type:AlphaSMSMessageTypeWapPush recipient:recipient sender:sender scheduleDate:nil expirationDate:nil wapURL:wapURL];
}

// setup wap-push message for sending at given date with given expiration period
+ (AlphaSMSMessage *)wapMessageWithText:(NSString *)text
                                 wapURL:(NSString *)wapURL
                              recipient:(NSString *)recipient
                                 sender:(NSString *)sender
                           scheduleDate:(NSDate *)scheduleDate
                         expirationDate:(NSDate *)expirationDate
{
    return [AlphaSMSMessage messageWithText:text type:AlphaSMSMessageTypeWapPush recipient:recipient sender:sender scheduleDate:scheduleDate expirationDate:expirationDate wapURL:wapURL];
}

@end
