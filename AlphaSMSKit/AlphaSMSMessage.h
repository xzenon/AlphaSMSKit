//
//  AlphaSMSMessage.h
//  AlphaSMSKit
//
//  Created by Xenon on 10/10/13.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AlphaSMSMessageType)
{    
    AlphaSMSMessageTypeSMS      =   0,  // standard SMS message
    AlphaSMSMessageTypeFlash    =   1,  // flash message
    AlphaSMSMessageTypeWapPush  =   2,  // wap-push message
    AlphaSMSMessageTypeVoice    =   3   // voice message (only for Ukrainian city phone numbers)
};

@interface AlphaSMSMessage : NSObject

@property (nonatomic) AlphaSMSMessageType type;         // message type
@property (nonatomic, strong) NSNumber *messageId;      // some message unique identifier (optional, if set by user - user must guarantee the id is unique for user's account scope)
@property (nonatomic, strong) NSString *recipient;      // recipient phone number, can include "+" (max length: 21 symbols)
@property (nonatomic, strong) NSString *sender;         // sender signature (max length: 11 symbols)
@property (nonatomic, strong) NSString *text;           // message text
@property (nonatomic, strong) NSDate *scheduleDate;     // date when message needs to be sent (optional)
@property (nonatomic, strong) NSDate *expirationDate;   // date of message expiration (if was scheduled) (min: 1 minute, max: 5 days from being sent, default: 1 day)
@property (nonatomic, strong) NSString *wapURL;         // URL link for wap-push messages

// setup message for sending immediately with default expiration date (1 day)
+ (AlphaSMSMessage *)messageWithText:(NSString *)text
                                type:(AlphaSMSMessageType)type
                           recipient:(NSString *)recipient
                              sender:(NSString *)sender;

// setup message for sending at given date with given expiration period
+ (AlphaSMSMessage *)messageWithText:(NSString *)text
                                type:(AlphaSMSMessageType)type
                           recipient:(NSString *)recipient
                              sender:(NSString *)sender
                        scheduleDate:(NSDate *)scheduleDate
                      expirationDate:(NSDate *)expirationDate;

// setup wap-push message for sending immediately with default expiration date (1 day)
+ (AlphaSMSMessage *)wapMessageWithText:(NSString *)text
                                 wapURL:(NSString *)wapURL
                              recipient:(NSString *)recipient
                                 sender:(NSString *)sender;

// setup wap-push message for sending at given date with given expiration period
+ (AlphaSMSMessage *)wapMessageWithText:(NSString *)text
                                 wapURL:(NSString *)wapURL
                              recipient:(NSString *)recipient
                                 sender:(NSString *)sender
                           scheduleDate:(NSDate *)scheduleDate
                         expirationDate:(NSDate *)expirationDate;

@end
