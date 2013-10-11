//
//  ViewController.m
//  AlphaSMSKitExample
//
//  Created by Xenon on 10/10/13.
//
//

#import "ViewController.h"
#import "AlphaSMSKit.h"
#import "AlphaSMSMessage.h"
#import "AlphaSMSMessageStatus.h"

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
    
    AlphaSMSMessage *message1 = [AlphaSMSMessage messageWithText:@"some text message" type:AlphaSMSMessageTypeSMS recipient:@"38066..." sender:@"TESTER"];
    AlphaSMSMessage *message2 = [AlphaSMSMessage messageWithText:@"some text message" type:AlphaSMSMessageTypeSMS recipient:@"38066..." sender:@"TESTER"];
    
    [alphaSmsKit sendMessages:@[message1,message2] success:^(NSArray *messageStatuses) {
        
        NSLog(@"*** MESSAGE %d STATUSES: %@", [messageStatuses count], messageStatuses);
        
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
