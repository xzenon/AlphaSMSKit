//
//  AlphaSMSMessageStatusRequest.m
//  AlphaSMSKitExample
//
//  Created by Xenon on 10/11/13.
//
//

#import "AlphaSMSMessageStatusRequest.h"

@interface AlphaSMSMessageStatusRequest()

@property (nonatomic, strong, readwrite) NSNumber *messageId;
@property (nonatomic, strong, readwrite) NSNumber *gatewayMessageId;

@end

@implementation AlphaSMSMessageStatusRequest

// setup message status request by given message ID
+ (AlphaSMSMessageStatusRequest *)messageStatusRequestWithMessageId:(NSNumber *)messageId
{
    AlphaSMSMessageStatusRequest *messageStatusRequest = [[AlphaSMSMessageStatusRequest alloc] init];
    messageStatusRequest.messageId = messageId;
    messageStatusRequest.gatewayMessageId = nil;
    return messageStatusRequest;
}

// setup message status request by given gateway message ID
+ (AlphaSMSMessageStatusRequest *)messageStatusRequestWithGatewayMessageId:(NSNumber *)gatewayMessageId
{
    AlphaSMSMessageStatusRequest *messageStatusRequest = [[AlphaSMSMessageStatusRequest alloc] init];
    messageStatusRequest.messageId = nil;
    messageStatusRequest.gatewayMessageId = gatewayMessageId;
    return messageStatusRequest;
}

@end
