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

static UIInterfaceOrientationMask _orientationMask = UIInterfaceOrientationMaskAllButUpsideDown;

+ (void)setSupportedOrientations:(UIInterfaceOrientationMask)orientationMask {
  if (_orientationMask != orientationMask) {
    _orientationMask = orientationMask;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
      [UIViewController attemptRotationToDeviceOrientation];
    }];
  }
}

+ (UIInterfaceOrientationMask)getSupportedOrientations {
  return _orientationMask;
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
  NSString *interfaceOrientationStr = [self getInterfaceOrientationStr];
  NSString *deviceOrientationStr = [self getDeviceOrientationStr];

  [self.bridge.eventDispatcher sendDeviceEventWithName:@"interfaceOrientationDidChange"
                                              body:@{@"orientation": interfaceOrientationStr}];
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"deviceOrientationDidChange"
                                              body:@{@"orientation": deviceOrientationStr}];
}

- (NSString *)getInterfaceOrientationStr {
  return [self getDeviceOrientationStr:[[UIApplication sharedApplication] statusBarOrientation]];
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

- (NSString *)getDeviceOrientationStr {
  return [self getDeviceOrientationStr:[[UIDevice currentDevice] orientation]];
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

RCT_EXPORT_METHOD(getInterfaceOrientation:(RCTResponseSenderBlock)callback)
{
  callback(@[[self getInterfaceOrientationStr]]);
}

RCT_EXPORT_METHOD(getDeviceOrientation:(RCTResponseSenderBlock)callback)
{
  callback(@[[self getDeviceOrientationStr]]);
}

RCT_EXPORT_METHOD(lockToPortrait)
{
  #if DEBUG
    NSLog(@"Locked to Portrait");
  #endif
  [Orientation setSupportedOrientations:UIInterfaceOrientationMaskPortrait];
}

RCT_EXPORT_METHOD(lockToLandscape)
{
  #if DEBUG
    NSLog(@"Locked to Landscape");
  #endif
  [Orientation setSupportedOrientations:UIInterfaceOrientationMaskLandscape];
}

RCT_EXPORT_METHOD(lockToLandscapeLeft)
{
  #if DEBUG
    NSLog(@"Locked to Landscape Left");
  #endif
    [Orientation setSupportedOrientations:UIInterfaceOrientationMaskLandscapeLeft];
}

RCT_EXPORT_METHOD(lockToLandscapeRight)
{
  #if DEBUG
    NSLog(@"Locked to Landscape Right");
  #endif
  [Orientation setSupportedOrientations:UIInterfaceOrientationMaskLandscapeRight];
}

RCT_EXPORT_METHOD(unlockAllOrientations)
{
  #if DEBUG
    NSLog(@"Unlock All Orientations");
  #endif
  [Orientation setSupportedOrientations:UIInterfaceOrientationMaskAllButUpsideDown];
}

- (NSDictionary *)constantsToExport
{

  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getDeviceOrientationStr:orientation];

  return @{
    @"initialInterfaceOrientation": [self getInterfaceOrientationStr],
    @"initialDeviceOrientation": [self getDeviceOrientationStr]
  };
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

@end
