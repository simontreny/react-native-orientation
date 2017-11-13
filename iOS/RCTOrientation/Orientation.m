//
//  Orientation.m
//

#import "Orientation.h"
#if __has_include(<React/RCTEventDispatcher.h>)
#import <React/RCTEventDispatcher.h>
#else
#import "RCTEventDispatcher.h"
#endif

@implementation Orientation
@synthesize bridge = _bridge;

static UIInterfaceOrientationMask _orientation = UIInterfaceOrientationMaskAllButUpsideDown;
+ (void)setOrientation: (UIInterfaceOrientationMask)orientation {
  _orientation = orientation;
}
+ (UIInterfaceOrientationMask)getOrientation {
  return _orientation;
}

- (instancetype)init
{
  if ((self = [super init])) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
  }
  return self;

}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getOrientationStr:orientation];
  NSString *deviceOrientationStr = [self getDeviceOrientationStr:orientation];

  [self.bridge.eventDispatcher sendDeviceEventWithName:@"orientationDidChange"
                                              body:@{@"orientation": orientationStr}];
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"deviceOrientationDidChange"
                                              body:@{@"orientation": deviceOrientationStr}];
}

- (NSString *)getOrientationStr:(UIDeviceOrientation)orientation {
  switch (orientation) {
    case UIDeviceOrientationPortrait:
    case UIDeviceOrientationPortraitUpsideDown:
      return @"PORTRAIT";

    case UIDeviceOrientationLandscapeLeft:
    case UIDeviceOrientationLandscapeRight:
      return @"LANDSCAPE";

    default:
      // orientation is unknown, we try to get the status bar orientation
      switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
          return @"PORTRAIT";

        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
          return @"LANDSCAPE";

        default:
          return @"UNKNOWN";
      }
  }
}

- (NSString *)getDeviceOrientationStr:(UIDeviceOrientation)orientation {
  switch (orientation) {
    case UIDeviceOrientationPortrait:
      return @"PORTRAIT";

    case UIDeviceOrientationPortraitUpsideDown:
      return @"PORTRAIT-UPSIDEDOWN";

    case UIDeviceOrientationLandscapeLeft:
      return @"LANDSCAPE-LEFT";

    case UIDeviceOrientationLandscapeRight:
      return @"LANDSCAPE-RIGHT";

    default:
      return @"UNKNOWN";
  }
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getOrientation:(RCTResponseSenderBlock)callback)
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getOrientationStr:orientation];
  callback(@[orientationStr]);
}

RCT_EXPORT_METHOD(getDeviceOrientation:(RCTResponseSenderBlock)callback)
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getDeviceOrientationStr:orientation];
  callback(@[orientationStr]);
}

RCT_EXPORT_METHOD(lockToPortrait)
{
  #if DEBUG
    NSLog(@"Locked to Portrait");
  #endif
  [Orientation setOrientation:UIInterfaceOrientationMaskPortrait];
  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
  }];

}

RCT_EXPORT_METHOD(lockToLandscape)
{
  #if DEBUG
    NSLog(@"Locked to Landscape");
  #endif
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getDeviceOrientationStr:orientation];
  if ([orientationStr isEqualToString:@"LANDSCAPE-LEFT"]) {
    [Orientation setOrientation:UIInterfaceOrientationMaskLandscape];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
      [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
    }];
  } else {
    [Orientation setOrientation:UIInterfaceOrientationMaskLandscape];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
      [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    }];
  }
}

RCT_EXPORT_METHOD(lockToLandscapeLeft)
{
  #if DEBUG
    NSLog(@"Locked to Landscape Left");
  #endif
    [Orientation setOrientation:UIInterfaceOrientationMaskLandscapeLeft];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
    }];

}

RCT_EXPORT_METHOD(lockToLandscapeRight)
{
  #if DEBUG
    NSLog(@"Locked to Landscape Right");
  #endif
  [Orientation setOrientation:UIInterfaceOrientationMaskLandscapeRight];
  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
  }];

}

RCT_EXPORT_METHOD(unlockAllOrientations)
{
  #if DEBUG
    NSLog(@"Unlock All Orientations");
  #endif
  [Orientation setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
}

- (NSDictionary *)constantsToExport
{

  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getOrientationStr:orientation];

  return @{
    @"initialOrientation": orientationStr
  };
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

@end
