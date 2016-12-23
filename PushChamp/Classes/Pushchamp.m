//
//  PushchampSDK.m
//  PushchampSDK
//
//  Created by Abhinav Singh on 06/10/15.
//  Copyright © 2015 Abhinav Singh. All rights reserved.
//

#import "Pushchamp.h"

@implementation PushchampSubscription

-(id) init:(NSString*)app_id
{
    if( self = [super init] )
    {
        app = app_id;
    }
    return self;
}

-(void) register:(NSString*)token
{
    NSLog(@"Registering Token : %@", token);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sid = [defaults stringForKey:@"pushchamp_subscriptionid"];
    NSLog(@"SID = %@", sid);
    
    [PushchampSubscription makeCall: self->app
                              token: token
                    subscription_id: sid
                           add_tags: nil
                        delete_tags: nil
                         add_groups: nil
                      delete_groups: nil];
}

-(void) updateTags:(NSDictionary *)add_tags delete_tags:(NSArray *)delete_tags
{
    //NSLog(@"Updating tags ...");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sid = [defaults stringForKey:@"pushchamp_subscriptionid"];
    //NSLog(@"SID = %@", sid);
    
    if ([sid length]!=0) {
        [PushchampSubscription makeCall: self->app
                                  token: nil
                        subscription_id: sid
                               add_tags: add_tags
                            delete_tags: delete_tags
                             add_groups: nil
                          delete_groups: nil];
    }
}

-(void) addTag:(NSString *)key value:(NSString *)value
{
    //NSLog(@"Adding tag ...");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sid = [defaults stringForKey:@"pushchamp_subscriptionid"];
    NSMutableDictionary *add_tags = [[NSMutableDictionary alloc]init];
    [add_tags setObject:value forKey:key];

    //NSLog(@"SID = %@", sid);
    
    if ([sid length]!=0) {
        [PushchampSubscription makeCall: self->app
                                  token: nil
                        subscription_id: sid
                               add_tags: add_tags
                            delete_tags: nil
                             add_groups: nil
                          delete_groups: nil];
    }
}

-(void) addEmail:(NSString *)email
{
    [self addTag:@"email" value:email];
}

-(void) addMobile:(NSString *)mobile
{
    [self addTag:@"mobile" value:mobile];
}

-(void) addUserID:(NSString *)uid
{
    [self addTag:@"unique_id" value:uid];
}

-(void) deleteTag:(NSString *)key
{
    //NSLog(@"Deleting tag ...");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sid = [defaults stringForKey:@"pushchamp_subscriptionid"];
    NSMutableArray *delete_tags = [[NSMutableArray alloc]init];
    [delete_tags addObject:key];
    //NSLog(@"SID = %@", sid);
    
    if ([sid length]!=0) {
        [PushchampSubscription makeCall: self->app
                                  token: nil
                        subscription_id: sid
                               add_tags: nil
                            delete_tags: delete_tags
                             add_groups: nil
                          delete_groups: nil];
    }
}

-(void) deleteEmail
{
    [self deleteTag:@"email"];
}

-(void) deleteMobile
{
    [self deleteTag:@"mobile"];
}

-(void) deleteUserID
{
    [self deleteTag:@"unique_id"];
}

-(void) addGroups:(NSArray *)add_groups
{
    //NSLog(@"Adding groups ...");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sid = [defaults stringForKey:@"pushchamp_subscriptionid"];
    //NSLog(@"SID = %@", sid);
    
    if ([sid length]!=0) {
        [PushchampSubscription makeCall: self->app
                                  token: nil
                        subscription_id: sid
                               add_tags: nil
                            delete_tags: nil
                             add_groups: add_groups
                          delete_groups: nil];
    }
}


-(void) deleteGroups:(NSArray *)delete_groups
{
    //NSLog(@"Deleting groups ...");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sid = [defaults stringForKey:@"pushchamp_subscriptionid"];
    //NSLog(@"SID = %@", sid);
    
    if ([sid length]!=0) {
        [PushchampSubscription makeCall: self->app
                                  token: nil
                        subscription_id: sid
                               add_tags: nil
                            delete_tags: nil
                             add_groups: nil
                          delete_groups: delete_groups];
    }
}

+(void) makeCall:(NSString *)app
                    token: (NSString *)token
                    subscription_id:(NSString *)subscription_id
                    add_tags:(NSDictionary *)add_tags
                    delete_tags:(NSArray *)delete_tags
                    add_groups:(NSArray *)add_groups
                    delete_groups:(NSArray *)delete_groups
{
    NSURL *url = [NSURL URLWithString:@"https://www.pushchamp.com/subscribe/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSMutableString* requestBody = [[NSMutableString alloc] init];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:app forKey:@"app"];
    if (add_tags!=nil) {
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:add_tags options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        [params setObject:[NSString stringWithFormat: @"%@", jsonString] forKey:@"add_tags"];
    }
    if (delete_tags!=nil) {
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:delete_tags options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        [params setObject:[NSString stringWithFormat: @"%@", jsonString] forKey:@"delete_tags"];
    }
    if (add_groups!=nil) {
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:add_groups options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        [params setObject:[NSString stringWithFormat: @"%@", jsonString] forKey:@"add_groups"];
    }
    if (delete_groups!=nil) {
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:delete_groups options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        [params setObject:[NSString stringWithFormat: @"%@", jsonString] forKey:@"delete_groups"];
    }

    if (token!=nil) {
        [params setObject:token forKey:@"notification_token"];
    }
    
    [params setObject:@"ios" forKey:@"platform"];
    
    if (subscription_id!=nil) {
        [params setObject:[NSString stringWithFormat: @"%@", subscription_id] forKey:@"subscription_id"];
    }
    
    for (id key in params) {
        [requestBody appendFormat: @"%@=%@&", key,params[key]];
    }
    NSString* requestBodyString = [NSString stringWithString:requestBody];
    NSData *requestData = [NSData dataWithBytes: [requestBodyString UTF8String] length: [requestBodyString length]];
    [request setHTTPBody: requestData];
    [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@", data);
        if (data.length > 0 && error == nil)
        {
            NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:NULL];
            NSLog(@"%@",  greeting[@"subscription_id"] );
            if ([greeting[@"status"] isEqualToString: @"success"]){
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setValue: greeting[@"subscription_id"] forKey:@"pushchamp_subscriptionid"];
                [defaults synchronize];
                NSLog(@"Pushchamp registration/update successful.");
            }
        }
    }];
}

@end
