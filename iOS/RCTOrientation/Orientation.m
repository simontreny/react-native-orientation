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
  NSString *orientationStr = [self getDeviceOrientationStr:orientation fallbackToStatusBarOrientation:YES];
  NSString *deviceOrientationStr = [self getDeviceOrientationStr:orientation fallbackToStatusBarOrientation:NO];

  [self.bridge.eventDispatcher sendDeviceEventWithName:@"orientationDidChange"
                                              body:@{@"orientation": orientationStr}];
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"deviceOrientationDidChange"
                                              body:@{@"orientation": deviceOrientationStr}];
}

- (NSString *)getDeviceOrientationStr:(UIDeviceOrientation)orientation fallbackToStatusBarOrientation:(BOOL)fallbackToStatusBar {
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
      if (fallbackToStatusBar) {
        return [self getInterfaceOrientationStr:[[UIApplication sharedApplication] statusBarOrientation]];
      } else {
        return @"UNKNOWN";
      }
  }
}

- (NSString *)getInterfaceOrientationStr:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return @"PORTRAIT";
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"PORTRAIT-UPSIDEDOWN";
            
        case UIInterfaceOrientationLandscapeLeft:
            return @"LANDSCAPE-LEFT";
            
        case UIInterfaceOrientationLandscapeRight:
            return @"LANDSCAPE-RIGHT";
            
        default:
            return @"UNKNOWN";
    }
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getOrientation:(RCTResponseSenderBlock)callback)
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getDeviceOrientationStr:orientation fallbackToStatusBarOrientation:YES];
  callback(@[orientationStr]);
}

RCT_EXPORT_METHOD(getDeviceOrientation:(RCTResponseSenderBlock)callback)
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSString *orientationStr = [self getDeviceOrientationStr:orientation fallbackToStatusBarOrientation:NO];
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
  NSString *orientationStr = [self getDeviceOrientationStr:orientation fallbackToStatusBarOrientation:YES];
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
  NSString *orientationStr = [self getDeviceOrientationStr:orientation fallbackToStatusBarOrientation:YES];

  return @{
    @"initialOrientation": orientationStr
  };
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

@end
