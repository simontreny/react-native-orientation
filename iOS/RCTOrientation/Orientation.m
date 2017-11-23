//
//  Orientation.m
//

#import "Orientation.h"
#if __has_include(<React/RCTEventDispatcher.h>)
#import <React/RCTEventDispatcher.h>
#else
#import "RCTEventDispatcher.h"
#endif

@interface Orientation () {
  UIInterfaceOrientation _interfaceOrientation;
  UIDeviceOrientation _deviceOrientation;
}
@end

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
    _interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    _deviceOrientation = [[UIDevice currentDevice] orientation];
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
  _interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  _deviceOrientation = [[UIDevice currentDevice] orientation];

  [self.bridge.eventDispatcher sendDeviceEventWithName:@"interfaceOrientationDidChange"
                                              body:@{@"orientation": [self getInterfaceOrientationStr]}];
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"deviceOrientationDidChange"
                                                  body:@{@"orientation": [self getDeviceOrientationStr]}];
}

- (NSString *)getInterfaceOrientationStr {
  return [self getInterfaceOrientationStr:_interfaceOrientation];
}

- (NSString *)getInterfaceOrientationStr:(UIInterfaceOrientation)orientation {
  switch (orientation) {
    case UIInterfaceOrientationPortrait:
      return @"PORTRAIT";
      
    case UIInterfaceOrientationPortraitUpsideDown:
      return @"PORTRAIT-UPSIDEDOWN";
      
    case UIInterfaceOrientationLandscapeLeft:
      return @"LANDSCAPE-RIGHT";
      
    case UIInterfaceOrientationLandscapeRight:
      return @"LANDSCAPE-LEFT";
      
    default:
      return @"UNKNOWN";
  }
}

- (NSString *)getDeviceOrientationStr {
  return [self getDeviceOrientationStr:_deviceOrientation];
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
  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
  }];
}

RCT_EXPORT_METHOD(lockToLandscape)
{
  #if DEBUG
    NSLog(@"Locked to Landscape");
  #endif
  [Orientation setSupportedOrientations:UIInterfaceOrientationMaskLandscape];
  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
    if (_deviceOrientation == UIDeviceOrientationLandscapeLeft) {
      [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    } else {
      [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeRight] forKey:@"orientation"];
    }
  }];
}

RCT_EXPORT_METHOD(lockToLandscapeLeft)
{
  #if DEBUG
    NSLog(@"Locked to Landscape Left");
  #endif
  [Orientation setSupportedOrientations:UIInterfaceOrientationMaskLandscapeRight];
  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
  }];
}

RCT_EXPORT_METHOD(lockToLandscapeRight)
{
  #if DEBUG
    NSLog(@"Locked to Landscape Right");
  #endif
  [Orientation setSupportedOrientations:UIInterfaceOrientationMaskLandscapeLeft];
  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeRight] forKey:@"orientation"];
  }];
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
