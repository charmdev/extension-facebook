#import <CallbacksDelegate.h>
#import <Facebook.h>
#import <UIKit/UIKit.h>
#import <AuthenticationServices/AuthenticationServices.h>
#import <SafariServices/SafariServices.h>
#import <FBSDKCoreKit/FBSDKCoreKit-Swift.h>


@implementation NMEAppDelegate (CallbacksDelegate)

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	NSLog(@"openURL");
	
	return [[FBSDKApplicationDelegate sharedInstance] application:application
									openURL:url
									sourceApplication:sourceApplication
									annotation:annotation];
}

@end
