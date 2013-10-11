//
//  AlphaSMSKit.h
//  AlphaSMSKit
//
//  Created by Xenon on 10/10/13.
//
//

#import <UIKit/UIKit.h>

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

- (void)sendMessages:(NSArray *)messages
             success:(void (^)(NSArray *messageStatuses))success
             failure:(void (^)(NSError *error))failure;

@end
