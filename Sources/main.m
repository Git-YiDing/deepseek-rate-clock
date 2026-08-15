/*
 * SPDX-License-Identifier: MIT
 * Copyright (c) 2026 DeepSeek Rate Clock contributors
 */

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DSPhase) {
    DSPhasePending = 0,
    DSPhaseOffPeak = 1,
    DSPhasePeak = 2,
};

@interface DSPolicySnapshot : NSObject
@property(nonatomic, assign) DSPhase phase;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *detail;
@property(nonatomic, copy) NSString *countdown;
@property(nonatomic, strong) NSDate *transitionDate;
@property(nonatomic, readonly) BOOL discounted;
@end

@implementation DSPolicySnapshot
- (BOOL)discounted {
    return self.phase == DSPhaseOffPeak;
}
@end

static NSTimeZone *DSBeijingTimeZone(void) {
    static NSTimeZone *timeZone;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    });
    return timeZone;
}

static NSCalendar *DSBeijingCalendar(void) {
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        calendar.timeZone = DSBeijingTimeZone();
    });
    return calendar;
}

static NSDate *DSEffectiveDate(void) {
    static NSDate *date;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.timeZone = DSBeijingTimeZone();
        components.year = 2026;
        components.month = 8;
        components.day = 17;
        components.hour = 0;
        components.minute = 0;
        components.second = 0;
        date = [DSBeijingCalendar() dateFromComponents:components];
    });
    return date;
}

static NSDate *DSDateAtHour(NSDate *date, NSInteger hour) {
    NSCalendar *calendar = DSBeijingCalendar();
    NSCalendarUnit units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:units fromDate:date];
    components.timeZone = DSBeijingTimeZone();
    components.hour = hour;
    components.minute = 0;
    components.second = 0;
    return [calendar dateFromComponents:components];
}

static NSString *DSFormatDuration(NSTimeInterval interval) {
    NSInteger totalSeconds = MAX(0, (NSInteger)ceil(interval));
    NSInteger days = totalSeconds / 86400;
    NSInteger remainder = totalSeconds % 86400;
    NSInteger hours = remainder / 3600;
    NSInteger minutes = (remainder % 3600) / 60;
    NSInteger seconds = remainder % 60;

    if (days > 0) {
        return [NSString stringWithFormat:@"%ld天 %02ld:%02ld:%02ld",
                                          (long)days,
                                          (long)hours,
                                          (long)minutes,
                                          (long)seconds];
    }
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",
                                      (long)hours,
                                      (long)minutes,
                                      (long)seconds];
}

static DSPolicySnapshot *DSSnapshotAtDate(NSDate *date) {
    DSPolicySnapshot *snapshot = [[DSPolicySnapshot alloc] init];

    if ([date compare:DSEffectiveDate()] == NSOrderedAscending) {
        snapshot.phase = DSPhasePending;
        snapshot.title = @"新优惠尚未生效";
        snapshot.detail = @"当前仍为统一价 · 2026-08-17 00:00（北京）起生效";
        snapshot.transitionDate = DSEffectiveDate();
        snapshot.countdown = [@"距生效  " stringByAppendingString:
            DSFormatDuration([snapshot.transitionDate timeIntervalSinceDate:date])];
        return snapshot;
    }

    NSDate *nine = DSDateAtHour(date, 9);
    NSDate *twelve = DSDateAtHour(date, 12);
    NSDate *fourteen = DSDateAtHour(date, 14);
    NSDate *eighteen = DSDateAtHour(date, 18);

    if ([date compare:nine] == NSOrderedAscending) {
        snapshot.phase = DSPhaseOffPeak;
        snapshot.transitionDate = nine;
    } else if ([date compare:twelve] == NSOrderedAscending) {
        snapshot.phase = DSPhasePeak;
        snapshot.transitionDate = twelve;
    } else if ([date compare:fourteen] == NSOrderedAscending) {
        snapshot.phase = DSPhaseOffPeak;
        snapshot.transitionDate = fourteen;
    } else if ([date compare:eighteen] == NSOrderedAscending) {
        snapshot.phase = DSPhasePeak;
        snapshot.transitionDate = eighteen;
    } else {
        NSDate *tomorrow = [DSBeijingCalendar() dateByAddingUnit:NSCalendarUnitDay
                                                           value:1
                                                          toDate:date
                                                         options:0];
        snapshot.phase = DSPhaseOffPeak;
        snapshot.transitionDate = DSDateAtHour(tomorrow, 9);
    }

    if (snapshot.discounted) {
        snapshot.title = @"空闲时段 · 半价";
        snapshot.detail = @"DeepSeek API 空闲价格为高峰价格的一半";
        snapshot.countdown = [@"距高峰  " stringByAppendingString:
            DSFormatDuration([snapshot.transitionDate timeIntervalSinceDate:date])];
    } else {
        snapshot.title = @"高峰时段 · 未优惠";
        snapshot.detail = @"北京时间 09:00–12:00、14:00–18:00 为高峰";
        snapshot.countdown = [@"距半价  " stringByAppendingString:
            DSFormatDuration([snapshot.transitionDate timeIntervalSinceDate:date])];
    }
    return snapshot;
}

@interface DSAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
@property(nonatomic, strong) NSStatusItem *statusItem;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSDateFormatter *menuBarTimeFormatter;
@property(nonatomic, strong) NSDateFormatter *localTimeFormatter;
@property(nonatomic, strong) NSDateFormatter *beijingTimeFormatter;
@property(nonatomic, strong) NSMenuItem *localTimeItem;
@property(nonatomic, strong) NSMenuItem *beijingTimeItem;
@property(nonatomic, strong) NSMenuItem *statusTitleItem;
@property(nonatomic, strong) NSMenuItem *statusDetailItem;
@property(nonatomic, strong) NSMenuItem *countdownItem;
@property(nonatomic, strong) NSImage *greenDotImage;
@property(nonatomic, strong) NSImage *redDotImage;
@property(nonatomic, copy) NSString *lastStatusBarTitle;
@property(nonatomic, assign) BOOL menuOpen;
@end

@implementation DSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    (void)notification;
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [self configureFormatters];
    [self buildStatusItem];
    [self updateStatus];

    self.timer = [NSTimer timerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(updateStatus)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(systemTimeZoneDidChange:)
                                                 name:NSSystemTimeZoneDidChangeNotification
                                               object:nil];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    (void)notification;
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureFormatters {
    NSLocale *chineseLocale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];

    self.menuBarTimeFormatter = [[NSDateFormatter alloc] init];
    self.menuBarTimeFormatter.locale = chineseLocale;
    self.menuBarTimeFormatter.timeZone = [NSTimeZone localTimeZone];
    self.menuBarTimeFormatter.dateFormat = @"HH:mm";

    self.localTimeFormatter = [[NSDateFormatter alloc] init];
    self.localTimeFormatter.locale = chineseLocale;
    self.localTimeFormatter.timeZone = [NSTimeZone localTimeZone];
    self.localTimeFormatter.dateFormat = @"yyyy年M月d日 EEE  HH:mm:ss";

    self.beijingTimeFormatter = [[NSDateFormatter alloc] init];
    self.beijingTimeFormatter.locale = chineseLocale;
    self.beijingTimeFormatter.timeZone = DSBeijingTimeZone();
    self.beijingTimeFormatter.dateFormat = @"M月d日 EEE  HH:mm:ss";
}

- (NSMenuItem *)informationItemWithTitle:(NSString *)title {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
    item.enabled = NO;
    return item;
}

- (void)buildStatusItem {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSStatusBarButton *button = self.statusItem.button;
    button.imagePosition = NSImageLeft;
    button.font = [NSFont monospacedDigitSystemFontOfSize:12.0 weight:NSFontWeightMedium];
    self.greenDotImage = [self dotImageWithColor:[NSColor systemGreenColor]];
    self.redDotImage = [self dotImageWithColor:[NSColor systemRedColor]];

    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"DeepSeek Rate Clock"];
    menu.autoenablesItems = NO;
    menu.delegate = self;

    self.statusTitleItem = [self informationItemWithTitle:@"当前状态  --"];
    self.statusDetailItem = [self informationItemWithTitle:@"--"];
    self.countdownItem = [self informationItemWithTitle:@"--"];
    [menu addItem:self.statusTitleItem];
    [menu addItem:self.statusDetailItem];
    [menu addItem:self.countdownItem];
    [menu addItem:[NSMenuItem separatorItem]];

    self.localTimeItem = [self informationItemWithTitle:@"当地时间  --:--:--"];
    self.beijingTimeItem = [self informationItemWithTitle:@"北京时间  --:--:--"];
    [menu addItem:self.localTimeItem];
    [menu addItem:self.beijingTimeItem];
    [menu addItem:[NSMenuItem separatorItem]];

    [menu addItem:[self informationItemWithTitle:@"高峰  北京 09:00–12:00 · 14:00–18:00"]];
    [menu addItem:[self informationItemWithTitle:@"绿：空闲半价  ·  红：未优惠"]];
    [menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *pricingItem = [[NSMenuItem alloc] initWithTitle:@"查看 DeepSeek 官方价格…"
                                                          action:@selector(openOfficialPricing:)
                                                   keyEquivalent:@""];
    pricingItem.target = self;
    pricingItem.enabled = YES;
    [menu addItem:pricingItem];

    NSMenuItem *aboutItem = [[NSMenuItem alloc] initWithTitle:@"关于 DeepSeek Rate Clock"
                                                        action:@selector(showAbout:)
                                                 keyEquivalent:@""];
    aboutItem.target = self;
    aboutItem.enabled = YES;
    [menu addItem:aboutItem];
    [menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"退出 DeepSeek Rate Clock"
                                                       action:@selector(quitApplication:)
                                                keyEquivalent:@"q"];
    quitItem.target = self;
    quitItem.enabled = YES;
    [menu addItem:quitItem];

    self.statusItem.menu = menu;
}

- (NSImage *)dotImageWithColor:(NSColor *)color {
    NSImage *image = [NSImage imageWithSize:NSMakeSize(10.0, 10.0)
                                    flipped:NO
                             drawingHandler:^BOOL(NSRect destinationRect) {
        [color setFill];
        [[NSBezierPath bezierPathWithOvalInRect:NSInsetRect(destinationRect, 1.0, 1.0)] fill];
        return YES;
    }];
    image.template = NO;
    return image;
}

- (void)updateStatus {
    NSDate *now = [NSDate date];
    DSPolicySnapshot *snapshot = DSSnapshotAtDate(now);
    BOOL green = snapshot.discounted;
    NSImage *dotImage = green ? self.greenDotImage : self.redDotImage;

    NSString *shortState;
    if (snapshot.phase == DSPhasePending) {
        shortState = @"待生效";
    } else if (snapshot.phase == DSPhaseOffPeak) {
        shortState = @"半价";
    } else {
        shortState = @"未优惠";
    }

    NSStatusBarButton *button = self.statusItem.button;
    NSString *statusBarTitle = [NSString stringWithFormat:@"%@ %@",
                                                          shortState,
                                                          [self.menuBarTimeFormatter stringFromDate:now]];
    if (![statusBarTitle isEqualToString:self.lastStatusBarTitle]) {
        button.image = dotImage;
        button.title = statusBarTitle;
        button.toolTip = [NSString stringWithFormat:@"DeepSeek API · %@ · %@",
                                                   snapshot.title,
                                                   snapshot.countdown];
        button.accessibilityLabel = [NSString stringWithFormat:@"DeepSeek API，%@，%@",
                                                               snapshot.title,
                                                               snapshot.countdown];
        self.lastStatusBarTitle = statusBarTitle;
    }

    if (self.menuOpen) {
        self.localTimeItem.title = [@"当地时间  " stringByAppendingString:
            [self.localTimeFormatter stringFromDate:now]];
        self.beijingTimeItem.title = [@"北京时间  " stringByAppendingString:
            [self.beijingTimeFormatter stringFromDate:now]];
        self.statusTitleItem.title = [@"当前状态  " stringByAppendingString:snapshot.title];
        self.statusTitleItem.image = dotImage;
        self.statusDetailItem.title = snapshot.detail;
        self.countdownItem.title = snapshot.countdown;
    }
}

- (void)menuWillOpen:(NSMenu *)menu {
    (void)menu;
    self.menuOpen = YES;
    [self updateStatus];
}

- (void)menuDidClose:(NSMenu *)menu {
    (void)menu;
    self.menuOpen = NO;
}

- (void)systemTimeZoneDidChange:(NSNotification *)notification {
    (void)notification;
    [NSTimeZone resetSystemTimeZone];
    self.menuBarTimeFormatter.timeZone = [NSTimeZone localTimeZone];
    self.localTimeFormatter.timeZone = [NSTimeZone localTimeZone];
    self.lastStatusBarTitle = nil;
    [self updateStatus];
}

- (void)openOfficialPricing:(id)sender {
    (void)sender;
    NSURL *url = [NSURL URLWithString:@"https://api-docs.deepseek.com/zh-cn/quick_start/pricing/"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)showAbout:(id)sender {
    (void)sender;
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:nil];
}

- (void)quitApplication:(id)sender {
    (void)sender;
    [NSApp terminate:nil];
}

@end

static NSDate *DSISODate(NSString *value) {
    NSISO8601DateFormatter *formatter = [[NSISO8601DateFormatter alloc] init];
    return [formatter dateFromString:value];
}

static NSString *DSPhaseName(DSPhase phase) {
    switch (phase) {
        case DSPhasePending: return @"pending";
        case DSPhaseOffPeak: return @"off_peak";
        case DSPhasePeak: return @"peak";
    }
}

static int DSRunSelfTests(void) {
    NSArray<NSDictionary<NSString *, id> *> *testCases = @[
        @{@"name": @"before effective time", @"date": @"2026-08-16T15:59:59Z", @"phase": @(DSPhasePending)},
        @{@"name": @"effective instant / Beijing midnight", @"date": @"2026-08-16T16:00:00Z", @"phase": @(DSPhaseOffPeak)},
        @{@"name": @"one second before first peak", @"date": @"2026-08-17T00:59:59Z", @"phase": @(DSPhaseOffPeak)},
        @{@"name": @"09:00 Beijing enters peak", @"date": @"2026-08-17T01:00:00Z", @"phase": @(DSPhasePeak)},
        @{@"name": @"12:00 Beijing enters off-peak", @"date": @"2026-08-17T04:00:00Z", @"phase": @(DSPhaseOffPeak)},
        @{@"name": @"14:00 Beijing enters peak", @"date": @"2026-08-17T06:00:00Z", @"phase": @(DSPhasePeak)},
        @{@"name": @"18:00 Beijing enters off-peak", @"date": @"2026-08-17T10:00:00Z", @"phase": @(DSPhaseOffPeak)},
        @{@"name": @"next day before peak", @"date": @"2026-08-17T23:30:00Z", @"phase": @(DSPhaseOffPeak)},
    ];

    NSInteger failures = 0;
    for (NSDictionary<NSString *, id> *testCase in testCases) {
        NSString *name = testCase[@"name"];
        NSDate *date = DSISODate(testCase[@"date"]);
        DSPhase expected = [testCase[@"phase"] integerValue];
        DSPhase actual = DSSnapshotAtDate(date).phase;
        if (actual == expected) {
            fprintf(stdout, "PASS  %s\n", name.UTF8String);
        } else {
            fprintf(stdout,
                    "FAIL  %s: expected %s, got %s\n",
                    name.UTF8String,
                    DSPhaseName(expected).UTF8String,
                    DSPhaseName(actual).UTF8String);
            failures += 1;
        }
    }

    if (failures == 0) {
        fprintf(stdout, "All policy boundary tests passed.\n");
        return 0;
    }
    fprintf(stdout, "%ld test(s) failed.\n", (long)failures);
    return 1;
}

static int DSPrintCurrentStatus(void) {
    DSPolicySnapshot *snapshot = DSSnapshotAtDate([NSDate date]);
    fprintf(stdout, "%s | %s | %s\n",
            snapshot.title.UTF8String,
            snapshot.detail.UTF8String,
            snapshot.countdown.UTF8String);
    return 0;
}

int main(int argc, const char *argv[]) {
    (void)argc;
    (void)argv;
    @autoreleasepool {
        NSArray<NSString *> *arguments = [NSProcessInfo processInfo].arguments;
        if ([arguments containsObject:@"--self-test"]) {
            return DSRunSelfTests();
        }
        if ([arguments containsObject:@"--status"]) {
            return DSPrintCurrentStatus();
        }

        NSApplication *application = [NSApplication sharedApplication];
        static DSAppDelegate *applicationDelegate;
        applicationDelegate = [[DSAppDelegate alloc] init];
        application.delegate = applicationDelegate;
        [application setActivationPolicy:NSApplicationActivationPolicyAccessory];
        [application run];
    }
    return 0;
}
