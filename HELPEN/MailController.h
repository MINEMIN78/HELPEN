//
//  MailController.h
//  mailtest
//
//  Created by YUMAKOMORI on 2016/03/29.
//  Copyright © 2016年 YUMAKOMORI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

@interface MailController : NSObject

-(void) sendEmail:(NSString *) host:(NSString *) port:(NSString *) username:(NSString *) password:(NSString *) sendAddress:(NSString *) receiveAddress:(NSString *) message;


@end
