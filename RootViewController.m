/**
 * Name: CrashGenerator
 * Type: iOS app
 * Desc: iOS app to test different types of crashes.
 *
 * Author: Lance Fetters (aka. ashikase)
 * License: Apache License, version 2.0
 *          (http://www.apache.org/licenses/LICENSE-2.0)
 */

#import "RootViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "LRFStatusPopup.h"

static void simulateExcResourceMemory() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        while (1) {
            sleep(1);
        }
    });
}

static void simulateExcResourceCPU() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        while (1) {}
    });
}

static void simulateExcResourceWakeups() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        while (1) { usleep(100); }
    });
}

static void handleCrashNotification(CFNotificationCenterRef center, void *observer,
        CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if ([(id)observer isKindOfClass:[RootViewController class]]) {
        [(id)observer performSelector:@selector(handleCrashNotification)];
    }
}

@implementation RootViewController {
    LRFStatusPopup *statusPopup_;
    uint64_t routineStartTime_;
}

#pragma mark - Creation and Destruction

- (id)init {
    self = [super init];
    if (self != nil) {
        [self setTitle:@"Select Type to Generate"];

        // Listen for crashes.
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                self, handleCrashNotification, CFSTR("jp.ashikase.crashreporter.notifier.crash"), NULL, 0);
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [statusPopup_ release];
    [super dealloc];
}

#pragma mark - Delegate (UITableViewDataSource)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"EXC_RESOURCE";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
    }

    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;

    NSString *text = nil;
    switch (section) {
        case 0:
            switch (row) {
                case 0: text = @"Memory";  break;
                case 1: text = @"CPU";     break;
                case 2: text = @"Wakeups"; break;
                default: break;
            }
            break;
        default:
            break;
    }
    cell.textLabel.text = text;

    return cell;
}

#pragma mark - Delegate (UITableViewDelegate)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;

    NSString *text = nil;
    NSString *subtype = nil;
    switch (section) {
        case 0:
            text = @"EXC_RESOURCE";
            switch (row) {
                case 0:
                    simulateExcResourceMemory();
                    subtype = @"Memory";
                    break;
                case 1:
                    simulateExcResourceCPU();
                    subtype = @"CPU";
                    break;
                case 2:
                    simulateExcResourceWakeups();
                    subtype = @"Wakeups";
                    break;
                default: break;
            }
            break;
        default:
            break;
    }

    if (text != nil) {
        LRFStatusPopup *statusPopup = [LRFStatusPopup new];
        statusPopup.textLabel.text = text;
        statusPopup.detailTextLabel.text = [NSString stringWithFormat:@"Generating for type \"%@\".", subtype];
        [statusPopup setShowsElapsedTime:YES];
        [statusPopup show:YES];
        [statusPopup startElapsedTimer];
        statusPopup_ = statusPopup;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Notifications

- (void)handleCrashNotification {
    [statusPopup_ stopElapsedTimer];
    [statusPopup_ hide:YES blinkCount:3];
    [statusPopup_ release];
    statusPopup_ = nil;
}

@end

/* vim: set ft=objc ff=unix sw=4 ts=4 tw=80 expandtab: */
