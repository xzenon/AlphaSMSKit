AlphaSMSKit
===========

Objective-C API wrapper for [AlphaSMS](http://alphasms.ua/) service. AlphaSMS provides technical platform and software for sending different types of Short Messages (SMS) in Ukraine, Russia and all over the world.

Current release is based on XML POST v1.5 protocol. 
Full protocol description is available as [PDF document](http://alphasms.ua/storage/files/AlphaSMS_XML_v1.5.pdf) (in russian).
For more technical details look the official [TechDoc page](http://alphasms.ua/about/techdocs/).

## Requirements
  * iOS 5.0 and greater (4.3 should work too with proper version of AFNetworking)
  * ARC

If you wish to use AlphaSMSKit in a non-ARC project, just add the **-fobjc-arc** compiler flag to all **AlphaSMS*.m** classes.

## Features
  * send SMS, wap-push, flash and voice messages
  * check message status
  * delete scheduled messages
  * check current balance

## How to get started
### Installation
Download the AlphaSMSKit folder and add it to your project.

### Dependencies
AlphaSMSKit requires the following libraries:
  * [AFNetworking](https://github.com/AFNetworking/AFNetworking) by Mattt Thompson and other contributors
  * [XMLDictionary](https://github.com/nicklockwood/XMLDictionary) by Charcoal Design

You can install those dependencies by copying files to your project or via [Cocoapods](http://cocoapods.org/) by adding the following lines to your Podfile:
```objective-c
pod "AFNetworking", "1.3.3"
pod "XMLDictionary", "1.3"
```

Note that if you want to target iOS 5 you have to use AFNetworking version 1.x (while te latest 2.x does not support iOS 5). For iOS 4.3 compatibility use lates 0.10.x AFNetworking version.

### Include header file
Put the following declaration to the top of *.m file where you intend to use AlphaSMSKit:
```objective-c
#import "AlphaSMSKit.h"
```

### Configuration
To use AlphaSMS backend via API your secret key needs to be passed with each call.
To find your secret key [log in to AlphaSMS](http://alphasms.ua/account) and open Account configuration page - your key should be listed on "API" tab.

Before making calls put put the following code where it is appropriate (to yout AppDelegate.m or your ViewController's viewDidLoad method, for example) and replace *SECRET_KEY* with your proper key value:
```objective-c
[AlphaSMSKit setSecretKey:@"SECRET_KEY"];
```

Now you're ready to make API calls.

## Structure

AlphaSMSKit uses the such  helper classes for manipulating messages, statuses and requests:
   * `AlphaSMSMessage` - used to configure messages to be sent
   * `AlphaSMSMessageStatus` - returned as result after sending/deleting/quering for message status
   * `AlphaSMSMessageStatusRequest` - used for configuring message delete/status requests

### AlphaSMSMessage

`AlphaSMSMessage` class generally describes SMS message using the following structure:

```objective-c
// message type
@property (nonatomic) AlphaSMSMessageType type;

// some message unique identifier (optional, if set by user - user must 
// guarantee the id is unique for user's account scope)
@property (nonatomic, strong) NSNumber *messageId;

// recipient phone number, can include "+" (max length: 21 symbols)
@property (nonatomic, strong) NSString *recipient;

// sender signature (max length: 11 symbols)
@property (nonatomic, strong) NSString *sender;

// message text
@property (nonatomic, strong) NSString *text;

// date when message needs to be sent (optional)
@property (nonatomic, strong) NSDate *scheduleDate;

// date of message expiration (if was scheduled)
// (min: 1 minute, max: 5 days from being sent, default: 1 day)
@property (nonatomic, strong) NSDate *expirationDate;

// URL link for wap-push messages
@property (nonatomic, strong) NSString *wapURL;
```

To create different types of messages use `AlphaSMSMessageType` values:
```objective-c
typedef NS_ENUM(NSUInteger, AlphaSMSMessageType)
{    
    AlphaSMSMessageTypeSMS      =   0,  // standard SMS message
    AlphaSMSMessageTypeFlash    =   1,  // flash message
    AlphaSMSMessageTypeWapPush  =   2,  // wap-push message
    AlphaSMSMessageTypeVoice    =   3   // voice message (only for Ukrainian city phone numbers)
};
```

To quickly configure `AlphaSMSMessage` use one of the following helper methods:
```objective-c
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
```

### AlphaSMSMessageStatus

`AlphaSMSMessageStatus` class describes message status received after calling send/delete/status methods. It has the following structure:

```objective-c
// message status code
@property (nonatomic, readonly) AlphaSMSMessageStatusCode statusCode;

// message identifier (set manually by user when sending message)
@property (nonatomic, strong, readonly) NSNumber *messageId;

// message identifier (set by SMS gateway automatically)
@property (nonatomic, strong, readonly) NSNumber *gatewayMessageId;

// actual SMS parts to be sent
@property (nonatomic, strong, readonly) NSNumber *smsCount;

// date when message final status was set
@property (nonatomic, strong, readonly) NSDate *completionDate;

// YES when message status code is one of 20X error codes
@property (nonatomic, readonly) BOOL isError;
```

`AlphaSMSMessageStatusCode` is used to determine current message status or error type (look to the PDF docs or source code to find more descriptions for status code values).

### AlphaSMSMessageStatusRequest

`AlphaSMSMessageStatusRequest` is used to pass to API the information about messages which statuses we want to receive. Structure:

```objective-c
// message identifier (one that set manually by user when sending message)
@property (nonatomic, strong, readonly) NSNumber *messageId;          

// message identifier (one that set by SMS gateway automatically)
@property (nonatomic, strong, readonly) NSNumber *gatewayMessageId;
```

To quickly configure `AlphaSMSMessageStatusRequest` use one of the following helper methods:
```objective-c
// setup message status request by given message ID
+ (AlphaSMSMessageStatusRequest *)messageStatusRequestWithMessageId:(NSNumber *)messageId;

// setup message status request by given gateway message ID
+ (AlphaSMSMessageStatusRequest *)messageStatusRequestWithGatewayMessageId:(NSNumber *)gatewayMessageId;
```


## Usage
### Send SMS messages

To send SMS message (you can send one or more per one call) use the following method:
```objective-c
+(void)sendMessages:(NSArray *)messages 
            success:(void (^)(NSArray *messageStatuses))success 
            failure:(void (^)(NSError *error))failure;
```

`(NSArray *)messages` is an array containing one or more instances of `AlphaSMSMessage`.

Resulting `(NSArray *)messageStatuses` is an array containing one or more instances of `AlphaSMSMessageStatus`.

Example code for sending standard SMS message:
```objective-c
//setup message
AlphaSMSMessage *message = [AlphaSMSMessage messageWithText:@"Some text message" 
                                                       type:AlphaSMSMessageTypeSMS 
                                                  recipient:@"+380502223344" 
                                                     sender:@"SENDER"];
//send it    
[AlphaSMSKit sendMessages:@[message1] success:^(NSArray *messageStatuses) { 
    NSLog(@"Response: %@", messageStatuses); 
} failure:^(NSError *error) { 
    NSLog(@"Error: %@", error);
}];
```

### Delete SMS messages

To delete message (one or more per call) use the following method:
```objective-c
+ (void)deleteMessages:(NSArray *)messageRequests 
              success:(void (^)(NSArray *messageStatuses))success 
              failure:(void (^)(NSError *error))failure;
```

`(NSArray *)messageRequests` is an array containing one or more instances of `AlphaSMSMessageStatusRequest`.

Resulting `(NSArray *)messageStatuses` is an array containing one or more instances of `AlphaSMSMessageStatus`.

Example code for sending standard SMS message:
```objective-c
//use previously saved message ID to setup message status request
AlphaSMSMessageStatusRequest *statusRequest = [AlphaSMSMessageStatusRequest messageStatusRequestWithGatewayMessageId:messageGatewayId];
    
//delete message and get it's status
[AlphaSMSKit deleteMessages:@[statusRequest] success:^(NSArray *messageStatuses) {
    NSLog(@"Response: %@", messageStatuses);
} failure:^(NSError *error) {
    NSLog(@"Error: %@", error);
}];
```

### Query for message status

To determine current message status (one or more per call) use the following method:
```objective-c
+ (void)getMessageStatuses:(NSArray *)messageRequests 
                   success:(void (^)(NSArray *messageStatuses))success 
                   failure:(void (^)(NSError *error))failure;
```

`(NSArray *)messageRequests` is an array containing one or more instances of `AlphaSMSMessageStatusRequest`.

Resulting `(NSArray *)messageStatuses` is an array containing one or more instances of `AlphaSMSMessageStatus`.

Example code for sending standard SMS message:
```objective-c
//use previously saved message ID to setup message status request
AlphaSMSMessageStatusRequest *statusRequest = [AlphaSMSMessageStatusRequest messageStatusRequestWithGatewayMessageId:messageGatewayId];
    
//get message status
[AlphaSMSKit getMessageStatuses:@[statusRequest] success:^(NSArray *messageStatuses) {
    NSLog(@"Response: %@", messageStatuses);
} failure:^(NSError *error) {
    NSLog(@"Error: %@", error);
}];
```

### Check user's balance

To get the current available amount on your balance use the following method:
```objective-c
+ (void)getBalanceWithSuccess:(void (^)(NSNumber *amount, NSString *currency))success 
                      failure:(void (^)(NSError *error))failure;
```

`NSNumber *amount` is a available money amount, `NSString *currency` is a string describing used currency.

### Demo project

For demo and more details please check the included **AlphaSMSKitExample** example project.

## License

AlphaSMSKit is available under the MIT license. See the LICENSE file for more info.
