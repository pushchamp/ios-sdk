//
//  PushchampSDK.h
//  PushchampSDK
//
//  Created by Abhinav Singh on 06/10/15.
//  Copyright © 2015 Abhinav Singh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushchampSubscription : NSObject
{
    NSString *app;
}

-(id) init: (NSString*)salt;
-(void) register:(NSString*)token;
-(void) updateTags:(NSDictionary*)add_tags delete_tags:(NSArray*)delete_tags;
-(void) addTag:(NSString*)key value:(NSString*)value;
-(void) deleteTag:(NSString*)key;
-(void) addGroups:(NSArray*)groups;
-(void) deleteGroups:(NSArray*)groups;
-(void) addEmail:(NSString*)email;
-(void) addMobile:(NSString*)mobile;
-(void) addUserID:(NSString*)uid;
-(void) deleteEmail;
-(void) deleteMobile;
-(void) deleteUserID;

@end
