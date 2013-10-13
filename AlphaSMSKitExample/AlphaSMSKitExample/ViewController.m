//
//  ViewController.m
//  AlphaSMSKitExample
//
//  Created by Xenon on 10/10/13.
//
//

#import "ViewController.h"
#import "AlphaSMSKit.h"

static NSString *phoneNumber;
static NSNumber *messageGatewayId;

@interface ViewController()

@property (nonatomic, strong) UIButton *balanceButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *statusButton;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#warning Set your secret key and some phone number to test API calls
    
    //set your secret key here
    [AlphaSMSKit setSecretKey:@"SECRET_KEY"];
    
    //set some phone number for tests
    phoneNumber = @"+38050....";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //add "balance" button
    self.balanceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.balanceButton.frame = CGRectMake(10, 100, self.view.frame.size.width - 20, 40);
    self.balanceButton.backgroundColor = [UIColor lightGrayColor];
    [self.balanceButton setTintColor:[UIColor blackColor]];
    [self.balanceButton setTitle:@"Check balance" forState:UIControlStateNormal];
    [self.balanceButton addTarget:self action:@selector(checkBalance) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.balanceButton];
    
    //add "send" button
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sendButton.frame = CGRectMake(10, 170, self.view.frame.size.width - 20, 40);
    self.sendButton.backgroundColor = [UIColor lightGrayColor];
    [self.sendButton setTintColor:[UIColor blackColor]];
    [self.sendButton setTitle:[@"Send SMS to " stringByAppendingString:phoneNumber] forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];
    
    //add "status" button
    self.statusButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.statusButton.frame = CGRectMake(10, 240, self.view.frame.size.width - 20, 40);
    self.statusButton.backgroundColor = [UIColor lightGrayColor];
    [self.statusButton setTintColor:[UIColor blackColor]];
    [self.statusButton setTitle:@"Get message status" forState:UIControlStateNormal];
    [self.statusButton addTarget:self action:@selector(getMessageStatus) forControlEvents:UIControlEventTouchUpInside];
    self.statusButton.enabled = NO;
    [self.view addSubview:self.statusButton];
    
    //add "delete" button
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.deleteButton.frame = CGRectMake(10, 310, self.view.frame.size.width - 20, 40);
    self.deleteButton.backgroundColor = [UIColor lightGrayColor];
    [self.deleteButton setTintColor:[UIColor blackColor]];
    [self.deleteButton setTitle:@"Delete message" forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteMessage) forControlEvents:UIControlEventTouchUpInside];
    self.deleteButton.enabled = NO;
    [self.view addSubview:self.deleteButton];
}

//------------------------------------------------------------

#pragma mark - Button handlers

- (void)sendMessage
{
    // standard SMS message
    //----------------------
    AlphaSMSMessage *message1 = [AlphaSMSMessage messageWithText:@"Some text message"
                                                            type:AlphaSMSMessageTypeSMS
                                                       recipient:phoneNumber
                                                          sender:@"TESTING"];
    
    //uncomment to set schedule date and expiration date
    //message1.scheduleDate = [NSDate dateWithTimeIntervalSinceNow:3600];     // send message 1 hour later
    //message1.expirationDate = [NSDate dateWithTimeIntervalSinceNow:7200];   // expiration is 2 hours later
    
    /*
    // wap-push message
    //------------------
    AlphaSMSMessage *message2 = [AlphaSMSMessage wapMessageWithText:@"Wap-push message"
                                                             wapURL:@"http://google.com.ua"
                                                          recipient:phoneNumber
                                                             sender:@"TESTING"
                                                       scheduleDate:nil //no schedule
                                                     expirationDate:nil //default expiration date
                                 ];
     */
    
    [AlphaSMSKit sendMessages:@[message1] success:^(NSArray *messageStatuses) {
 
        //got response after sending messages
        NSLog(@"[SEND] Response: %@", messageStatuses);
        
        //get message status
        AlphaSMSMessageStatus *status = [messageStatuses objectAtIndex:0];
        [self showAlertWithTitle:@"Send message" message:[NSString stringWithFormat:@"Message status: %@", status]];
        
        //remember message ID defined by SMS gateway for further use
        messageGatewayId = status.gatewayMessageId;
        
        //enable "Status" and "Delete" buttons
        self.statusButton.enabled = YES;
        self.deleteButton.enabled = YES;
        
    } failure:^(NSError *error) {
        
        //error
        [self showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error]];
        NSLog(@"[SEND] Error: %@", error);
        
    }];
}

- (void)getMessageStatus
{
    //use previously saved message ID to setup message status request
    AlphaSMSMessageStatusRequest *statusRequest = [AlphaSMSMessageStatusRequest messageStatusRequestWithGatewayMessageId:messageGatewayId];

    //get message status
    [AlphaSMSKit getMessageStatuses:@[statusRequest]
                            success:^(NSArray *messageStatuses) {

                                //get message status
                                AlphaSMSMessageStatus *status = [messageStatuses objectAtIndex:0];
                                [self showAlertWithTitle:@"Got message status" message:[NSString stringWithFormat:@"Message status: %@", status]];
                                
                                NSLog(@"[STATUS] Response: %@", messageStatuses);
                                
                            } failure:^(NSError *error) {
                                
                                //error
                                [self showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error]];
                                NSLog(@"[STATUS] Error: %@", error);
                                
                            }];
}

- (void)deleteMessage
{
    //use previously saved message ID to setup message status request
    AlphaSMSMessageStatusRequest *statusRequest = [AlphaSMSMessageStatusRequest messageStatusRequestWithGatewayMessageId:messageGatewayId];
    
    //get message status
    [AlphaSMSKit deleteMessages:@[statusRequest]
                        success:^(NSArray *messageStatuses) {
                                
                            //get message status
                            AlphaSMSMessageStatus *status = [messageStatuses objectAtIndex:0];
                            [self showAlertWithTitle:@"Delete message" message:[NSString stringWithFormat:@"Message status: %@", status]];
                            
                            NSLog(@"[DELETE] Response: %@", messageStatuses);
                            
                        } failure:^(NSError *error) {
                            
                            //error
                            [self showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error]];
                            NSLog(@"[DELETE] Error: %@", error);
                            
                        }];
}

- (void)checkBalance
{
    //check user balance
    [AlphaSMSKit getBalanceWithSuccess:^(NSNumber *amount, NSString *currency) {

        //got balance info
        [self showAlertWithTitle:@"Check balance" message:[NSString stringWithFormat:@"Balance amount: %@ (%@)", amount, currency]];
        NSLog(@"[BALANCE] Amount: %@ (%@)", amount, currency);
        
    } failure:^(NSError *error) {
        
        //error
        [self showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error]];
        NSLog(@"[BALANCE] Error: %@", error);
        
    }];
}

//------------------------------------------------------------

#pragma mark - Utilities

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
