//
//  AlphaSMSMessageStatus.m
//  AlphaSMSKitExample
//
//  Created by Xenon on 10/10/13.
//
//

#import "AlphaSMSMessageStatus.h"

@interface AlphaSMSMessageStatus()

@property (nonatomic, readwrite) AlphaSMSMessageStatusCode statusCode; // message status code
@property (nonatomic, strong, readwrite) NSNumber *messageId;          // message identifier (set manually by user when sending message)
@property (nonatomic, strong, readwrite) NSNumber *gatewayMessageId;   // message identifier (set by SMS gateway automatically)
@property (nonatomic, strong, readwrite) NSNumber *smsCount;           // actual SMS parts to be sent
@property (nonatomic, strong, readwrite) NSDate *completionDate;       // date when message final status was set
@property (nonatomic, readwrite) BOOL isError;                         // YES when message status code is one of 20X error codes

@end

@implementation AlphaSMSMessageStatus

// setup message status instance
+ (AlphaSMSMessageStatus *)messageStatusWithCode:(AlphaSMSMessageStatusCode)statusCode
                                       messageId:(NSNumber *)messageId
                                gatewayMessageId:(NSNumber *)gatewayMessageId
                                        smsCount:(NSNumber *)smsCount
                                  completionDate:(NSDate *)completionDate
{
    AlphaSMSMessageStatus *messageStatus = [[AlphaSMSMessageStatus alloc] init];
    messageStatus.statusCode = statusCode;
    messageStatus.messageId = messageId;
    messageStatus.gatewayMessageId = gatewayMessageId;
    messageStatus.smsCount = smsCount;
    messageStatus.completionDate = completionDate;
    messageStatus.isError = (messageStatus.statusCode == AlphaSMSMessageStatusErrorUnknown ||
                             messageStatus.statusCode == AlphaSMSMessageStatusErrorID ||
                             messageStatus.statusCode == AlphaSMSMessageStatusErrorSender ||
                             messageStatus.statusCode == AlphaSMSMessageStatusErrorRecipient ||
                             messageStatus.statusCode == AlphaSMSMessageStatusErrorLength ||
                             messageStatus.statusCode == AlphaSMSMessageStatusErrorUserDisable ||
                             messageStatus.statusCode == AlphaSMSMessageStatusErrorBilling ||
                             messageStatus.statusCode == AlphaSMSMessageStatusErrorOverlimit ||
                             messageStatus.statusCode == AlphaSMSMessageStatusErrorDuplicate ||
                             messageStatus.statusCode == AlphaSMSMessageStatusErrorDelete ||
                             messageStatus.statusCode == AlphaSMSMessageStatusErrorThrottle);
    return messageStatus;
}

+ (AlphaSMSMessageStatusCode)statusCodeFromInteger:(NSInteger)intCode
{
    switch (intCode) {
        case AlphaSMSMessageStatusSuccess: return AlphaSMSMessageStatusSuccess;

        case AlphaSMSMessageStatusErrorUnknown:     return AlphaSMSMessageStatusErrorUnknown;
        case AlphaSMSMessageStatusErrorID:          return AlphaSMSMessageStatusErrorID;
        case AlphaSMSMessageStatusErrorSender:      return AlphaSMSMessageStatusErrorSender;
        case AlphaSMSMessageStatusErrorRecipient:   return AlphaSMSMessageStatusErrorRecipient;
        case AlphaSMSMessageStatusErrorLength:      return AlphaSMSMessageStatusErrorLength;
        case AlphaSMSMessageStatusErrorUserDisable: return AlphaSMSMessageStatusErrorUserDisable;
        case AlphaSMSMessageStatusErrorBilling:     return AlphaSMSMessageStatusErrorBilling;
        case AlphaSMSMessageStatusErrorOverlimit:   return AlphaSMSMessageStatusErrorOverlimit;
        case AlphaSMSMessageStatusErrorDuplicate:   return AlphaSMSMessageStatusErrorDuplicate;
        case AlphaSMSMessageStatusErrorDelete:      return AlphaSMSMessageStatusErrorDelete;
        case AlphaSMSMessageStatusErrorThrottle:    return AlphaSMSMessageStatusErrorThrottle;
            
        case AlphaSMSMessageStatusScheduled:        return AlphaSMSMessageStatusScheduled;
        case AlphaSMSMessageStatusEnroute:          return AlphaSMSMessageStatusEnroute;
        case AlphaSMSMessageStatusDelivered:        return AlphaSMSMessageStatusDelivered;
        case AlphaSMSMessageStatusExpired:          return AlphaSMSMessageStatusExpired;
        case AlphaSMSMessageStatusDeleted:          return AlphaSMSMessageStatusDeleted;
        case AlphaSMSMessageStatusUndeliverable:    return AlphaSMSMessageStatusUndeliverable;
        case AlphaSMSMessageStatusAccepted:         return AlphaSMSMessageStatusAccepted;
        case AlphaSMSMessageStatusUnknown:          return AlphaSMSMessageStatusUnknown;
        case AlphaSMSMessageStatusRejected:         return AlphaSMSMessageStatusRejected;
        case AlphaSMSMessageStatusDiscarded:        return AlphaSMSMessageStatusDiscarded;
        case AlphaSMSMessageStatusSending:          return AlphaSMSMessageStatusSending;
        case AlphaSMSMessageStatusNotSupported:     return AlphaSMSMessageStatusNotSupported;
        case AlphaSMSMessageStatusWrongAlpha:       return AlphaSMSMessageStatusWrongAlpha;
        case AlphaSMSMessageStatusWrongAlphaReturned: return AlphaSMSMessageStatusWrongAlphaReturned;
            
        default: return AlphaSMSMessageStatusInvalid;
    }
}

- (NSString *)description
{
    NSDictionary *desc = @{@"id":(_messageId ? _messageId : [NSNull null]),
                           @"statusCode":[NSNumber numberWithInteger:_statusCode],
                           @"gatewayMessageId":(_gatewayMessageId ? _gatewayMessageId : [NSNull null]),
                           @"smsCount":(_smsCount ? _smsCount : [NSNull null]),
                           @"completionDate":(_completionDate ? _completionDate : [NSNull null]),
                           @"isError":(_isError ? @"YES" : @"NO")};
    return [NSString stringWithFormat:@"%@", desc];
}

@end
