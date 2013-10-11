//
//  AlphaSMSMessageStatus.h
//  AlphaSMSKitExample
//
//  Created by Xenon on 10/10/13.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AlphaSMSMessageStatusCode) 
{
    AlphaSMSMessageStatusInvalid            =   0,    // INVALID CODE
    
    AlphaSMSMessageStatusSuccess            =   1,    // NO ERROR
    
    AlphaSMSMessageStatusErrorUnknown       =   200,  // ERR_UNKNOWN: Unknown error
    AlphaSMSMessageStatusErrorID            =   201,  // ERR_ID: invalid message ID
    AlphaSMSMessageStatusErrorSender        =   202,  // ERR_SENDER: invalid sender value
    AlphaSMSMessageStatusErrorRecipient     =   203,  // ERR_RECIPIENT: invalid recipient value
    AlphaSMSMessageStatusErrorLength        =   204,  // ERR_LENGTH: message is empty or loo long
    AlphaSMSMessageStatusErrorUserDisable   =   205,  // ERR_USER_DISABLE: user is disabled
    AlphaSMSMessageStatusErrorBilling       =   206,  // ERR_BILLING: billing error
    AlphaSMSMessageStatusErrorOverlimit     =   207,  // ERR_OVERLIMIT: available messages limit was reached
    AlphaSMSMessageStatusErrorDuplicate     =   208,  // ERR_DUPLICATE: message with given ID is already exists
    AlphaSMSMessageStatusErrorDelete        =   211,  // ERR_DELETE: unable to delete message with given ID
    AlphaSMSMessageStatusErrorThrottle      =   212,  // ERR_ERR_THROTTLE: messages are sent too frequently
    
    AlphaSMSMessageStatusScheduled          =   100,   //SCHEDULED: The message is scheduled. Delivery has not yet been initiated.
    AlphaSMSMessageStatusEnroute            =   101,   //ENROUTE: The message is in enroute state.
    AlphaSMSMessageStatusDelivered          =   102,   //DELIVERED: Message is delivered to destination.
    AlphaSMSMessageStatusExpired            =   103,   //EXPIRED: Message validity period has expired.
    AlphaSMSMessageStatusDeleted            =   104,   //DELETED: Message has been deleted.
    AlphaSMSMessageStatusUndeliverable      =   105,   //UNDELIVERABLE: Message is undeliverable.
    AlphaSMSMessageStatusAccepted           =   106,   //ACCEPTED: Message is in accepted state (i.e. has been manually read on behalf of the subscriber by customer service).
    AlphaSMSMessageStatusUnknown            =   107,   //UNKNOWN: Message is in invalid state The message state is unknown.
    AlphaSMSMessageStatusRejected           =   108,   //REJECTED: Message is in a rejected state The message has been rejected by a delivery interface.
    AlphaSMSMessageStatusDiscarded          =   109,   //DISCARDED: Message discarded.
    AlphaSMSMessageStatusSending            =   110,   //SENDING: Message in process of transferring to mobile network.
    AlphaSMSMessageStatusNotSupported       =   111,   //NOT_SUPPORTED: Receiver’s operator is not supported. Message will not be billed.
    AlphaSMSMessageStatusWrongAlpha         =   112,   //WRONG_ALPHANAME : Alphaname (sender’s name) was not approved by operator. Only for Life:) Ukraine.
    AlphaSMSMessageStatusWrongAlphaReturned =   113    //WRONG_ALPHANAME_RETURNED: Alphaname (sender’s name) was not approved by operator. Money for SMS was returned. Only for Life:) Ukraine.
};

@interface AlphaSMSMessageStatus : NSObject

@property (nonatomic, readonly) AlphaSMSMessageStatusCode statusCode; // message status code
@property (nonatomic, strong, readonly) NSNumber *messageId;          // message identifier (set manually by user when sending message)
@property (nonatomic, strong, readonly) NSNumber *gatewayMessageId;   // message identifier (set by SMS gateway automatically)
@property (nonatomic, strong, readonly) NSNumber *smsCount;           // actual SMS parts to be sent
@property (nonatomic, strong, readonly) NSDate *completionDate;       // date when message final status was set
@property (nonatomic, readonly) BOOL isError;                         // YES when message status code is one of 20X error codes

// setup message status instance
- (AlphaSMSMessageStatus *)initMessageStatusWithCode:(AlphaSMSMessageStatusCode)statusCode
                                           messageId:(NSNumber *)messageId
                                    gatewayMessageId:(NSNumber *)gatewayMessageId
                                            smsCount:(NSNumber *)smsCount
                                      completionDate:(NSDate *)completionDate;

+ (AlphaSMSMessageStatusCode)statusCodeFromInteger:(NSInteger)intCode;

@end
