//
//  AlphaSMSKit.h
//  AlphaSMSKit
//
//  Created by Xenon on 10/10/13.
//
//

#import <UIKit/UIKit.h>

#import "AlphaSMSMessage.h"
#import "AlphaSMSMessageStatus.h"
#import "AlphaSMSMessageStatusRequest.h"

typedef NS_ENUM(NSUInteger, AlphaSMSServiceError)
{
    AlphaSMSServiceErrorInvalid       =   0,    // INVALID ERROR CODE
    AlphaSMSServiceErrorUnknown       =   200,  // ERR_UNKNOWN: Unknown error.
    AlphaSMSServiceErrorFormat        =   201,  // ERR_FORMAT: Invalid document format.
    AlphaSMSServiceErrorAuth          =   202,  // ERR_AUTHORIZATION: Authorization failed.
    AlphaSMSServiceErrorAPIDisabled   =   209,  // ERR_API_DISABLE: API was disabled by user.
    AlphaSMSServiceErrorIPDenied      =   210   // ERR_IP_DENIED: IP address is blacklisted.
};

@interface AlphaSMSKit : NSObject

// set your customer secret key
+ (void)setSecretKey:(NSString *)secretKey;

+ (AlphaSMSServiceError)errorCodeFromInteger:(NSInteger)intCode;

// attempt to send messages
// (NSArray *)messages: array of AlphaSMSMessage objects
- (void)sendMessages:(NSArray *)messages
             success:(void (^)(NSArray *messageStatuses))success
             failure:(void (^)(NSError *error))failure;

// attempt to get message statuses
// (NSArray *)messageRequests: array of AlphaSMSMessageStatusRequest objects
- (void)getMessageStatuses:(NSArray *)messageRequests
                   success:(void (^)(NSArray *messageStatuses))success
                   failure:(void (^)(NSError *error))failure;

@end
