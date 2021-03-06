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

- (void)setRecipient:(NSString *)recipient
{
    _recipient = (recipient.length > 21 ? [recipient substringToIndex:21] : recipient); //limit recipient string to 21 characters
}

- (void)setSender:(NSString *)sender
{
    _sender = (sender.length > 11 ? [sender substringToIndex:11] : sender); //limit sender string to 11 characters
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

- (NSString *)description
{
    NSDictionary *desc = @{@"id":(_messageId ? _messageId : [NSNull null]),
                           @"type":[NSNumber numberWithInteger:_type],
                           @"recipient":(_recipient ? _recipient : [NSNull null]),
                           @"sender":(_sender ? _sender : [NSNull null]),
                           @"text":(_text ? _text : [NSNull null]),
                           @"wapURL":(_wapURL ? _wapURL : [NSNull null]),
                           @"scheduleDate":(_scheduleDate ? _scheduleDate : [NSNull null]),
                           @"expirationDate":(_expirationDate ? _expirationDate : [NSNull null])
                           };
    return [NSString stringWithFormat:@"%@", desc];
}

@end
