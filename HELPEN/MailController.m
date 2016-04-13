//
//  MailController.m
//  mailtest
//
//  Created by YUMAKOMORI on 2016/03/29.
//  Copyright © 2016年 YUMAKOMORI. All rights reserved.
//


#import <MailCore/MailCore.h>
#import "MailController.h"


@implementation MailController

-(void) sendEmail:(NSString *) host:(NSString *) port:(NSString *) username:(NSString *) password:(NSString *) sendAddress:(NSString *) receiveAddress:(NSString *) message;
{
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = host;   // SMTPサーバのアドレス
    smtpSession.port = port;
    smtpSession.username = username;           // SMTPサーバのユーザ名
    smtpSession.password = password;        // SMTPサーバのパスワード
    smtpSession.authType = MCOAuthTypeSASLPlain;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    MCOAddress *from = [MCOAddress addressWithDisplayName:nil
                                                  mailbox:sendAddress];    // 送信元メールアドレス
    MCOAddress *to = [MCOAddress addressWithDisplayName:nil
                                                mailbox:receiveAddress];        // 送信先メールアドレス//
    [[builder header] setFrom:from];
    [[builder header] setTo:@[to]];
    [[builder header] setSubject:message];
    [builder setHTMLBody:message];
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation =
    [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"Error sending email: %@", error);
        } else {
            NSLog(@"Successfully sent email!");
        }
    }];
}

@end
