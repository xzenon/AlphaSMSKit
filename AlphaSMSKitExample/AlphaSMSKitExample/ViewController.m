//
//  ViewController.m
//  AlphaSMSKitExample
//
//  Created by Xenon on 10/10/13.
//
//

#import "ViewController.h"
#import "AlphaSMSKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AlphaSMSKit setSecretKey:@"d1210dfef3fb95fd69a473ed4ccd8c4d68443a5e"];
    
    AlphaSMSKit *alphaSmsKit = [[AlphaSMSKit alloc] init];
    
    AlphaSMSMessage *message1 = [AlphaSMSMessage messageWithText:@"some text message 1" type:AlphaSMSMessageTypeSMS recipient:@"38066..." sender:@"TESTER"];
    message1.scheduleDate = [NSDate date];
    message1.expirationDate = [NSDate dateWithTimeIntervalSinceNow:3600];
    
    //AlphaSMSMessage *message2 = [AlphaSMSMessage messageWithText:@"some text message 2" type:AlphaSMSMessageTypeSMS recipient:@"01234567890123456789012345" sender:@"TESTERTER12344"];
//    AlphaSMSMessage *message2 = [AlphaSMSMessage wapMessageWithText:@""
//                                                             wapURL:@"http://ex.ua"
//                                                          recipient:@"+38066..."
//                                                             sender:@"SEND"
//                                                       scheduleDate:[NSDate date]
//                                                     expirationDate:[NSDate dateWithTimeIntervalSinceNow:3600] ];
    
    [alphaSmsKit sendMessages:@[message1] success:^(NSArray *messageStatuses) {
        
        NSLog(@"*** MESSAGE STATUSES(%d) AFTER SENDING : %@", [messageStatuses count], messageStatuses);
        
        AlphaSMSMessageStatus *status = [messageStatuses objectAtIndex:0];
        AlphaSMSMessageStatusRequest *statusRequest = [AlphaSMSMessageStatusRequest messageStatusRequestWithGatewayMessageId:status.gatewayMessageId];
        
        [alphaSmsKit getMessageStatuses:@[statusRequest] success:^(NSArray *messageStatuses) {
            
            NSLog(@"*** GET MESSAGE STATUSES(%d) : %@", [messageStatuses count], messageStatuses);
            
        } failure:^(NSError *error) {
            NSLog(@"*** ERROR: %@", error);
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"*** ERROR: %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
