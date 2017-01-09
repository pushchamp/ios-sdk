//
//  PushchampSDK.h
//  PushchampSDK
//
//  Created by Abhinav Singh on 06/10/15.
//  Copyright © 2015 Abhinav Singh. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define NO_REACHABILITY_SUPPORT (defined(APP_EXTENSION) || defined(TVOS_EXTENSION) || defined(WATCH_EXTENSION))

@interface PushchampSubscription : NSObject
{
    NSString *app;
    NSUInteger _flushInterval;
}



@property (nonatomic, strong) NSTimer *timer;
@property (atomic) BOOL flushOnBackground;
@property (nonatomic, strong) NSMutableArray *eventsQueue;
@property (nonatomic) dispatch_queue_t serialQueue;



-(id) init: (NSString*)salt;
-(void) register:(NSString*)token;
-(void) updateTags:(NSDictionary*)add_tags delete_tags:(NSArray*)delete_tags;
-(void) addTag:(NSString*)key value:(NSString*)value;
-(void) deleteTag:(NSString*)key;
-(void) addGroups:(NSArray*)groups;
-(void) deleteGroups:(NSArray*)groups;
//-(void) makeCall:(NSString*)token
// subscription_id:(NSString *)deviceId
//        add_tags:(NSDictionary *)add_tags
//     delete_tags:(NSDictionary *)delete_tags;
-(void) makeCall:(NSString *)app_id
           token: (NSString *)token
 subscription_id:(NSString *)subscription_id
        add_tags:(NSDictionary *)add_tags
     delete_tags:(NSArray *)delete_tags
      add_groups:(NSArray *)add_groups
   delete_groups:(NSArray *)delete_groups;


-(void) sendEvent:(NSString *)app
               ev:(NSString *)ev
               et:(NSArray *)et;



- (void)track;
- (void)track:(NSString *)event properties:(nullable NSDictionary *)properties;

@end
