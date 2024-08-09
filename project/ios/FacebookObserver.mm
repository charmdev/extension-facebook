#import <Facebook.h>
#import <FacebookObserver.h>
#import <AuthenticationServices/AuthenticationServices.h>
#import <SafariServices/SafariServices.h>
#import <FBSDKCoreKit/FBSDKCoreKit-Swift.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>


@implementation FacebookObserver

- (void)observeTokenChange:(NSNotification *)notification {

	if ([FBSDKAccessToken currentAccessToken]!=nil) {
	//if ([FBSDKAuthenticationToken currentAuthenticationToken]!=nil) {
		extension_facebook::onTokenChange([[FBSDKAccessToken currentAccessToken].tokenString UTF8String]);

		//extension_facebook::onTokenChange(  [[FBSDKAuthenticationToken currentAuthenticationToken].tokenString UTF8String],
		//									[[FBSDKProfile currentProfile].userID UTF8String] );
	} else {
		extension_facebook::onTokenChange("");
	}
	
}

- (void) applicationDidFinishLaunchingNotification:(NSNotification *)notification {

	NSDictionary *launchOptions = [notification userInfo] ;
	[[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication]
								didFinishLaunchingWithOptions:launchOptions];

}

@end
