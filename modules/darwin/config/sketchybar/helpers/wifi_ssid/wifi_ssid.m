// Prints the current Wi-Fi SSID. Since macOS 14.4 every CLI source
// (ipconfig, networksetup, system_profiler, wdutil, even as root) returns
// <redacted>; CoreWLAN only hands it out to a process with Location Services
// authorization. CoreLocation refuses to even prompt for a bare executable, so
// this ships as a minimal .app bundle and is launched through `open`, which
// makes it its own responsible process with the usage description in Info.plist.
#import <CoreLocation/CoreLocation.h>
#import <CoreWLAN/CoreWLAN.h>

@interface Delegate : NSObject <CLLocationManagerDelegate>
@property BOOL determined;
@end

@implementation Delegate
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
  self.determined = manager.authorizationStatus != kCLAuthorizationStatusNotDetermined;
}
@end

int main(void) {
  @autoreleasepool {
    CLLocationManager *manager = [CLLocationManager new];
    Delegate *delegate = [Delegate new];
    manager.delegate = delegate;

    if (manager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
      [manager requestWhenInUseAuthorization];
      NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:60];
      while (!delegate.determined && [deadline timeIntervalSinceNow] > 0)
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    NSString *ssid = [CWWiFiClient sharedWiFiClient].interface.ssid;
    printf("%s\n", ssid ? ssid.UTF8String : "");
  }
  return 0;
}
