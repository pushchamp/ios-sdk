//
//  PushchampSDK.m
//  PushchampSDK
//
//  Created by Abhinav Singh on 06/10/15.
//  Copyright © 2015 Abhinav Singh. All rights reserved.
//

#import "Pushchamp.h"
#import "UIViewController+Utils.h"

#define NO_APP_LIFECYCLE_SUPPORT (defined(_APP_EXTENSION) || defined(_WATCH_EXTENSION))

@implementation PushchampSubscription

NSNumber* unSentActiveTime;
UIBackgroundTaskIdentifier focusBackgroundTask;
NSTimeInterval lastOpenedTime;
BOOL lastOnFocusWasToBackground = YES;


-(id) init:(NSString*)app_id
{
    if( self = [super init] )
    {
        app = app_id;
        
        _flushInterval = 60;
        self.eventsQueue = [[NSMutableArray alloc] init];
        
    }
    return self;
}

-(void) register:(NSString*)token
{
    NSLog(@"Registering Token : %@", token);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sid = [defaults stringForKey:@"pushchamp_subscriptionid"];
    NSLog(@"SID = %@", sid);
    
    double old_event_time = [defaults doubleForKey:@"LAST_OPENED_TIME"];
    NSDate *start = [NSDate dateWithTimeIntervalSince1970:(old_event_time / 1000.0)];;
    
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    
    
    long seconds = lroundf(timeInterval); // Since modulo operator (%) below needs int or long
    
    long mins = ((seconds % 3600) / 60)* -1;
    NSLog(@"Registering TIME DIfference Token : %ld", mins);
    
    if (mins > 5 ){
        [defaults setValue: token forKey:@"pushchamp_ssid"];
        [defaults setValue: app forKey:@"pushchamp_app"];
    }
    else{
        token = [defaults stringForKey:@"pushchamp_ssid"];
    }
    
    
    
    [self makeCall: self->app
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
        [self makeCall: self->app
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
        [self makeCall: self->app
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sid = [defaults stringForKey:@"pushchamp_subscriptionid"];
    NSMutableArray *delete_tags = [[NSMutableArray alloc]init];
    [delete_tags addObject:key];
    
    
    if ([sid length]!=0) {
        [self makeCall: self->app
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
        [self makeCall: self->app
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sid = [defaults stringForKey:@"pushchamp_subscriptionid"];
    
    
    if ([sid length]!=0) {
        [self makeCall: self->app
                 token: nil
       subscription_id: sid
              add_tags: nil
           delete_tags: nil
            add_groups: nil
         delete_groups: delete_groups];
    }
}

-(void) makeCall:(NSString *)app
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
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
                
                
                self.flushOnBackground = YES;
                [self setUpListeners];
                //[self unarchive];
                
            }
        }
    }];
    [dataTask resume];
}




-(void) sendEvent:(NSString *)app
               ev:(NSString *)ev
               et:(NSArray *)et
{
    
    
    NSMutableArray *array = [NSMutableArray alloc];
    array = [self readFromPlist];
    NSLog(@"SECONDS %lu",(unsigned long)[array count]);
    
    if ([array count] >= 5){
        
        NSURL *url = [NSURL URLWithString:@"https://api.pushchamp.com/v1/logevent/"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array
                                                           options:kNilOptions
                                                             error:&error];
        NSString *strDatas = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", strDatas);
        
        if (!jsonData) {
            NSLog(@"Achtung!  Failed to create JSON data: %@", [error localizedDescription]);
        }else{
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-length"];
            [request setHTTPBody:jsonData];
            
            NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@", strData);
                if (data.length > 0 && error == nil)
                {
                    NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:0
                                                                               error:NULL];
                    NSLog(@"%@",  greeting[@"status"] );
                    if ([greeting[@"status"] boolValue] == YES){
                        
                        
                        [self unarchive];
                        
                    }
                }
            }];
            [dataTask resume];
        }
        
        
        
    }
}


- (NSMutableArray *) readFromPlist {
    
    NSString *finalPath = [self eventsFilePath];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:finalPath];
    
    if (fileExists) {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithContentsOfFile:finalPath];
        return arr;
    } else {
        //        return nil;
        [self.eventsQueue writeToFile:finalPath atomically: YES];
        return self.eventsQueue;
    }
}

- (void)track
{
    
    self.eventsQueue = [self readFromPlist];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *subscription_id = [defaults stringForKey:@"pushchamp_subscriptionid"];
    NSString *ssid = [defaults stringForKey:@"pushchamp_ssid"];
    NSString *app_name = [defaults stringForKey:@"pushchamp_app"];
    NSTimeInterval now = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSInteger time = round(now);
    
    double old_event_time = [defaults doubleForKey:@"LAST_OPENED_TIME"];
    NSDate *start = [NSDate dateWithTimeIntervalSince1970:(old_event_time / 1000.0)];;
    
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    
    
    long seconds = lroundf(timeInterval); // Since modulo operator (%) below needs int or long
    
    
    int mins = ((seconds % 3600) / 60)* -1;
    long secs = seconds * -1;
    NSLog(@"Registering TIME DIfference Token : %ld", secs);
    
    
    [[NSUserDefaults standardUserDefaults] setDouble:now forKey:@"LAST_OPENED_TIME"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary *dict = [NSDictionary dictionary];
    NSDictionary *p;
    
    NSString *CurrentSelectedCViewController = NSStringFromClass([[UIViewController currentViewController] class]);
    
    
    if (old_event_time == 0 ){
        NSDictionary *new = [NSDictionary dictionaryWithObjectsAndKeys:
                             ssid, @"ssid",
                             subscription_id, @"sid",
                             app_name, @"app",
                             @"session_start", @"ev",
                             @"userEvent", @"ty",
                             [NSNumber numberWithLong:time], @"ts",
                             [NSNumber numberWithLong:secs], @"tfs",
                             @"ios", @"pf",
                             dict  ,@"et",
                             nil];
        
        [self.eventsQueue addObject:new];
        
        
    }
    else if (mins > 5){
        p = [NSDictionary dictionaryWithObjectsAndKeys:
             ssid, @"ssid",
             subscription_id, @"sid",
             app_name, @"app",
             @"session_end", @"ev",
             @"userEvent", @"ty",
             [NSNumber numberWithLong:time], @"ts",
             [NSNumber numberWithLong:secs], @"tfs",
             @"ios", @"pf",
             dict  ,@"et",
             nil];
        [self.eventsQueue addObject:p];
        
        NSDictionary *new = [NSDictionary dictionaryWithObjectsAndKeys:
                             ssid, @"ssid",
                             subscription_id, @"sid",
                             app_name, @"app",
                             @"session_start", @"ev",
                             @"userEvent", @"ty",
                             [NSNumber numberWithLong:time], @"ts",
                             [NSNumber numberWithLong:secs], @"tfs",
                             @"ios", @"pf",
                             dict  ,@"et",
                             nil];
        
        [self.eventsQueue addObject:new];
        
        
    }
    else{
        
        p = [NSDictionary dictionaryWithObjectsAndKeys:
             ssid, @"ssid",
             subscription_id, @"sid",
             app_name, @"app",
             CurrentSelectedCViewController, @"ev",
             @"userEvent", @"ty",
             [NSNumber numberWithLong:time], @"ts",
             [NSNumber numberWithLong:secs], @"tfs",
             @"ios", @"pf",
             dict  ,@"et",
             nil];
    }
    
    
    p = [NSDictionary dictionaryWithObjectsAndKeys:
         ssid, @"ssid",
         subscription_id, @"sid",
         app_name, @"app",
         CurrentSelectedCViewController, @"ev",
         @"userEvent", @"ty",
         [NSNumber numberWithLong:time], @"ts",
         [NSNumber numberWithLong:secs], @"tfs",
         @"ios", @"pf",
         dict  ,@"et",
         nil];
    
    
    
    NSLog(@"%@ queueing event: %@", self, p);
    NSLog(@"queueing COUNT______: %lu", (unsigned long)self.eventsQueue.count);
    [self.eventsQueue addObject:p];
    NSLog(@"queueing COUNT______: %lu", (unsigned long)self.eventsQueue.count);
    if (self.eventsQueue.count > 5000) {
        [self.eventsQueue removeObjectAtIndex:0];
    }
    
    // Always archive
    [self archiveEvents];
    [self sendEvent:app ev:CurrentSelectedCViewController  et:nil];
    
    
    
}




- (void)track:(NSString *)event properties:(NSDictionary *)properties
{
    self.eventsQueue = [self readFromPlist];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *subscription_id = [defaults stringForKey:@"pushchamp_subscriptionid"];
    NSString *ssid = [defaults stringForKey:@"pushchamp_ssid"];
    NSString *app_name = [defaults stringForKey:@"pushchamp_app"];
    NSTimeInterval now = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSInteger time = round(now);
    
    double old_event_time = [defaults doubleForKey:@"LAST_OPENED_TIME"];
    NSDate *start = [NSDate dateWithTimeIntervalSince1970:(old_event_time / 1000.0)];;
    
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    
    
    long seconds = lroundf(timeInterval); // Since modulo operator (%) below needs int or long
    
    
    int mins = ((seconds % 3600) / 60)* -1;
    long secs = seconds * -1;
    
    
    
    [[NSUserDefaults standardUserDefaults] setDouble:now forKey:@"LAST_OPENED_TIME"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary *dict = [NSDictionary dictionary];
    NSDictionary *p;
    NSString *CurrentSelectedCViewController = event;
    
    
    if (old_event_time == 0 ){
        NSDictionary *new = [NSDictionary dictionaryWithObjectsAndKeys:
                             ssid, @"ssid",
                             subscription_id, @"sid",
                             app_name, @"app",
                             @"session_start", @"ev",
                             @"userEvent", @"ty",
                             [NSNumber numberWithLong:time], @"ts",
                             [NSNumber numberWithLong:secs], @"tfs",
                             @"ios", @"pf",
                             dict  ,@"et",
                             nil];
        
        [self.eventsQueue addObject:new];
        
        
    }
    else if (mins > 5){
        p = [NSDictionary dictionaryWithObjectsAndKeys:
             ssid, @"ssid",
             subscription_id, @"sid",
             app_name, @"app",
             @"session_end", @"ev",
             @"userEvent", @"ty",
             [NSNumber numberWithLong:time], @"ts",
             [NSNumber numberWithLong:secs], @"tfs",
             @"ios", @"pf",
             dict  ,@"et",
             nil];
        [self.eventsQueue addObject:p];
        
        NSDictionary *new = [NSDictionary dictionaryWithObjectsAndKeys:
                             ssid, @"ssid",
                             subscription_id, @"sid",
                             app_name, @"app",
                             @"session_start", @"ev",
                             @"userEvent", @"ty",
                             [NSNumber numberWithLong:time], @"ts",
                             [NSNumber numberWithLong:secs], @"tfs",
                             @"ios", @"pf",
                             dict  ,@"et",
                             nil];
        
        [self.eventsQueue addObject:new];
        
        
    }
    else{
        
        p = [NSDictionary dictionaryWithObjectsAndKeys:
             ssid, @"ssid",
             subscription_id, @"sid",
             app_name, @"app",
             CurrentSelectedCViewController, @"ev",
             @"userEvent", @"ty",
             [NSNumber numberWithLong:time], @"ts",
             [NSNumber numberWithLong:secs], @"tfs",
             @"ios", @"pf",
             properties  ,@"et",
             nil];
    }
    
    
    p = [NSDictionary dictionaryWithObjectsAndKeys:
         ssid, @"ssid",
         subscription_id, @"sid",
         app_name, @"app",
         CurrentSelectedCViewController, @"ev",
         @"userEvent", @"ty",
         [NSNumber numberWithLong:time], @"ts",
         [NSNumber numberWithLong:secs], @"tfs",
         @"ios", @"pf",
         properties  ,@"et",
         nil];
    
    
    
    NSLog(@"%@ queueing event: %@", self, p);
    NSLog(@"queueing COUNT______: %lu", (unsigned long)self.eventsQueue.count);
    [self.eventsQueue addObject:p];
    NSLog(@"queueing COUNT______: %lu", (unsigned long)self.eventsQueue.count);
    if (self.eventsQueue.count > 5000) {
        [self.eventsQueue removeObjectAtIndex:0];
    }
    
    // Always archive
    [self archiveEvents];
    [self sendEvent:app ev:CurrentSelectedCViewController  et:nil];
    
}



//---------------------------------   LISTENERS   -----------------------------------------------


- (void)setUpListeners
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // Application lifecycle events
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillTerminate:)
                               name:UIApplicationWillTerminateNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillResignActive:)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidBecomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackground:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillEnterForeground:)
                               name:UIApplicationWillEnterForegroundNotification
                             object:nil];
    
    
    
    
}



- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    NSLog(@"%@ application did become active", self);
    _tfs = @"0";
    [self startTimer];
    
    
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    NSLog(@"%@ application will resign active", self);
    [self stopTimer];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    NSLog(@"%@ did enter background", self);
    __block UIBackgroundTaskIdentifier backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"%@ flush %lu cut short", self, (unsigned long) backgroundTask);
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        //self.taskId = UIBackgroundTaskInvalid;
    }];
    
    [self archive];
    
}

- (void)applicationWillEnterForeground:(NSNotificationCenter *)notification
{
    NSLog(@"%@ will enter foreground", self);
    
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSLog(@"%@ application will terminate", self);
    dispatch_async(_serialQueue, ^{
        [self archive];
    });
}



//---------------------------------  TIMER ---------------------------------------------


- (NSUInteger)flushInterval {
    return _flushInterval;
}

- (void)startTimer
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval timeToPingWith = 0.0;
    
    [[NSUserDefaults standardUserDefaults] setDouble:now forKey:@"GT_LAST_CLOSED_TIME"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSTimeInterval timeElapsed = now - lastOpenedTime + 0.5;
    if (timeElapsed < 0 || timeElapsed > 86400)
        return;
    
    NSTimeInterval unsentActive = [PushchampSubscription getUnsentActiveTime];
    NSTimeInterval totalTimeActive = unsentActive + timeElapsed;
    
    if (totalTimeActive < 30) {
        [PushchampSubscription saveUnsentActiveTime:totalTimeActive];
        return;
    }
    
    timeToPingWith = totalTimeActive;
    
    //[self stopTimer];
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        if (self.flushInterval > 0) {
    //            self.timer = [NSTimer scheduledTimerWithTimeInterval:_flushInterval
    //                                                          target:self
    //                                                        selector:@selector(flush)
    //                                                        userInfo:nil
    //                                                         repeats:YES];
    //            NSLog(@"%@ started flush timer: %@", self, self.timer);
    //        }
    //    });
}

- (void)stopTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.timer) {
            [self.timer invalidate];
            NSLog(@"%@ stopped timer: %@", self, self.timer);
            self.timer = nil;
        }
    });
}




+ (NSTimeInterval)getUnsentActiveTime {
    if (unSentActiveTime == NULL) {
        unSentActiveTime = [NSNumber numberWithInteger:-1];
    }
    
    if ([unSentActiveTime intValue] == -1) {
        unSentActiveTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"GT_UNSENT_ACTIVE_TIME"];
        if (unSentActiveTime == nil)
            unSentActiveTime = 0;
    }
    
    return [unSentActiveTime doubleValue];
}

+ (void)saveUnsentActiveTime:(NSTimeInterval)time {
    unSentActiveTime = @(time);
    [[NSUserDefaults standardUserDefaults] setObject:unSentActiveTime forKey:@"GT_UNSENT_ACTIVE_TIME"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}




- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





//-------------------------------------- SAVING DATA ----------------------------

#pragma mark - Persistence
- (NSString *)filePathFor:(NSString *)data
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ssid = [defaults stringForKey:@"pushchamp_ssid"];
    
    NSString *filename = [NSString stringWithFormat:@"pushChamp-%@-%@.plist", ssid, data];
    
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:filename];
    
}

- (NSString *)eventsFilePath
{
    return [self filePathFor:@"events"];
}

- (void)unarchive
{
    //    [self unarchiveEvents];
    NSError *error = NULL;
    BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:[self eventsFilePath] error:&error];
    if (!removed) {
        NSLog(@"%@ unable to remove archived file at %@ - %@", self, [self eventsFilePath], error);
    }
    
}

- (void)unarchiveEvents
{
    self.eventsQueue = (NSMutableArray *)[PushchampSubscription unarchiveOrDefaultFromFile:[self eventsFilePath] asClass:[NSMutableArray class]];
}

+ (nonnull id)unarchiveOrDefaultFromFile:(NSString *)filePath asClass:(Class)class
{
    return [self unarchiveFromFile:filePath asClass:class] ?: [class new];
}

+ (id)unarchiveFromFile:(NSString *)filePath asClass:(Class)class
{
    id unarchivedData = nil;
    @try {
        unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        // this check is inside the try-catch as the unarchivedData may be a non-NSObject, not responding to `isKindOfClass:` or `respondsToSelector:`
        if (![unarchivedData isKindOfClass:class]) {
            unarchivedData = nil;
        }
        NSLog(@"%@ unarchived data from %@: %@", self, filePath, unarchivedData);
    }
    @catch (NSException *exception) {
        NSLog(@"%@ unable to unarchive data in %@, starting fresh", self, filePath);
        // Reset un archived data
        unarchivedData = nil;
        // Remove the (possibly) corrupt data from the disk
        NSError *error = NULL;
        BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!removed) {
            NSLog(@"%@ unable to remove archived file at %@ - %@", self, filePath, error);
        }
    }
    return unarchivedData;
}




- (void)archive
{
    [self archiveEvents];
    
}

- (void)archiveEvents
{
    NSString *finalPath = [self eventsFilePath];
    
    [self.eventsQueue writeToFile:finalPath atomically: YES];
    
}

- (BOOL)archiveObject:(id)object withFilePath:(NSString *)filePath {
    @try {
        if (![NSKeyedArchiver archiveRootObject:object toFile:filePath]) {
            return NO;
        }
    } @catch (NSException* exception) {
        NSAssert(@"Got exception: %@, reason: %@.", exception.name, exception.reason);
        return NO;
    }
    
    [self addSkipBackupAttributeToItemAtPath:filePath];
    return YES;
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString
{
    NSURL *URL = [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if (!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}



- (void)reset
{
    dispatch_async(self.serialQueue, ^{
        
        self.eventsQueue = [NSMutableArray array];
        [self archive];
    });
}

@end
