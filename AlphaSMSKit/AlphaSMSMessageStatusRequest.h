//
//  AlphaSMSMessageStatusRequest.h
//  AlphaSMSKitExample
//
//  Created by Xenon on 10/11/13.
//
//

#import <Foundation/Foundation.h>

@interface AlphaSMSMessageStatusRequest : NSObject

@property (nonatomic, strong, readonly) NSNumber *messageId;          // message identifier (one that set manually by user when sending message)
@property (nonatomic, strong, readonly) NSNumber *gatewayMessageId;   // message identifier (one that set by SMS gateway automatically)

// setup message status request by given message ID
+ (AlphaSMSMessageStatusRequest *)messageStatusRequestWithMessageId:(NSNumber *)messageId;

// setup message status request by given gateway message ID
+ (AlphaSMSMessageStatusRequest *)messageStatusRequestWithGatewayMessageId:(NSNumber *)gatewayMessageId;

@end
