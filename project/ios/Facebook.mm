#import <CallbacksDelegate.h>
#import <Facebook.h>
#import <FacebookObserver.h>
#import <AuthenticationServices/AuthenticationServices.h>
#import <SafariServices/SafariServices.h>
#import <FBSDKCoreKit/FBSDKCoreKit-Swift.h>
#import <FBSDKLoginKit/FBSDKLoginKit-Swift.h>


namespace extension_facebook {

	FacebookObserver *obs;
	FBSDKLoginManager *login;
	UIViewController *root;

	void pre_init() {
		login = [[FBSDKLoginManager alloc] init];
		obs = [[FacebookObserver alloc] init];
		[[NSNotificationCenter defaultCenter]
			addObserver:obs
			selector:@selector(applicationDidFinishLaunchingNotification:)
			name:@"UIApplicationDidFinishLaunchingNotification"
			object:nil
		];
	}

	void init() {
		root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
		
		[[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication]
									didFinishLaunchingWithOptions:[[NSMutableDictionary alloc] init]];
		
		[obs observeTokenChange:nil];

		[[NSNotificationCenter defaultCenter]
			addObserver:obs
			selector:@selector(observeTokenChange:)
			name:FBSDKAccessTokenDidChangeNotification
			object:nil
		];
	}

	void setDebug() {
		//NSLog(@"Facebook: set debug mode");
		//[FBSDKSettings enableLoggingBehavior:FBSDKLoggingBehaviorAppEvents];
	}
	
	void logEvent(std::string name, std::string payload) {
		NSLog(@"Facebook: logEvent name= %s, payload= %s", name.c_str(), payload.c_str());
		
        NSString * nsName = [[NSString alloc] initWithUTF8String:name.c_str()];
        NSString * nsPayload = [[NSString alloc] initWithUTF8String:payload.c_str()];
		NSData * jsonData = [nsPayload dataUsingEncoding:NSUTF8StringEncoding];
		NSError * error = nil;
		NSDictionary * params = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
		
		//[FBSDKAppEvents logEvent:nsName parameters:params];
	}
	
	void logPurchase(double value, std::string currency, std::string payload) {

		return;
		
		NSLog(@"Facebook: logPurchase val=%f", value);
        NSLog(@"Facebook: logPurchase currency=%s", currency.c_str());
		NSLog(@"Facebook: logPurchase payload=%s", payload.c_str());
		
        NSString * nsCurrency = [[NSString alloc] initWithUTF8String:currency.c_str()];
		
		NSString * nsPayload = [[NSString alloc] initWithUTF8String:payload.c_str()];
		NSData * jsonData = [nsPayload dataUsingEncoding:NSUTF8StringEncoding];
		NSError * error = nil;
		NSDictionary * params = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
		
		//[FBSDKAppEvents logPurchase:value currency:nsCurrency parameters:params];
	}
	
	void logOut() {
		[login logOut];
	}

	void logInWithLimited(std::vector<std::string> &permissions) {
		NSMutableArray *nsPermissions = [[NSMutableArray alloc] init];
		for (auto p : permissions) {
			[nsPermissions addObject:[NSString stringWithUTF8String:p.c_str()]];
		}

		FBSDKLoginConfiguration *configuration = [[FBSDKLoginConfiguration alloc]
													initWithPermissions:nsPermissions
													tracking:FBSDKLoginTrackingLimited ];
												
		[login logInFromViewController:root
				configuration:configuration
				completion:^(FBSDKLoginManagerLoginResult * _Nullable result, NSError * _Nullable error) {
			
			if (error) {
				onLoginErrorCallback([error.localizedDescription UTF8String]);
			}else if (result.isCancelled) {
				onLoginCancelCallback();
			}else {
				onLoginSuccessCallback();
			}
		}];
		
	}

	void logInWithPublishPermissions(std::vector<std::string> &permissions) {
		NSMutableArray *nsPermissions = [[NSMutableArray alloc] init];
		for (auto p : permissions) {
			[nsPermissions addObject:[NSString stringWithUTF8String:p.c_str()]];
		}
		
		[login logInWithPermissions:nsPermissions fromViewController:root handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
			if (error) {
				onLoginErrorCallback([error.localizedDescription UTF8String]);
			} else if (result.isCancelled) {
				onLoginCancelCallback();
			} else {
				onLoginSuccessCallback();
			}
		}];
	}

	void logInWithReadPermissions(std::vector<std::string> &permissions) {
		NSMutableArray *nsPermissions = [[NSMutableArray alloc] init];
		for (auto p : permissions) {
			[nsPermissions addObject:[NSString stringWithUTF8String:p.c_str()]];
		}
		[login logInWithPermissions:nsPermissions fromViewController:root handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
			if (error) {
				onLoginErrorCallback([error.localizedDescription UTF8String]);
			} else if (result.isCancelled) {
				onLoginCancelCallback();
			} else {
				onLoginSuccessCallback();
			}
		}];
	}

	void shareLink(
		std::string contentURL,
		std::string contentTitle,
		std::string imageURL,
		std::string contentDescription) {
			
	}

	void appRequest(
		std::string message,
		std::string title,
		std::vector<std::string> &recipients,
		std::string objectId,
		int actionType,
		std::string data) {

	}

}
