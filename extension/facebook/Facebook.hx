
package extension.facebook;

#if android
import extension.facebook.android.FacebookCallbacks;
import extension.facebook.android.FacebookCFFI;
#elseif ios
import extension.facebook.ios.FacebookCFFI;
#end

import extension.util.task.*;
import flash.Lib;
import flash.net.URLRequest;
import haxe.Json;
import haxe.ds.StringMap;


@:enum
abstract PermissionsType(Int) {
	var Publish = 0;
	var Read = 1;
}

class Facebook extends TaskExecutor {

	static var initted = false;
	public var accessToken : String;

	private var initCallback:Bool->Void;
	private static var instance:Facebook=null;

	public static function getInstance():Facebook{
		if(instance==null) instance = new Facebook();
		return instance;
	}

	private function new() {
		accessToken = "";

		super();
	}

	public function init(initCallback:Bool->Void) {
		if (!initted) {
			#if (android || ios)
			this.initCallback = initCallback;
			FacebookCFFI.init(this.setAuthToken);
			#end
		}
	}

	public function setAuthToken(token:String) {
		if (token != "") {
			initted = true;
		}
		this.accessToken = token;
		if (this.initCallback != null) {
			this.initCallback(true);
		}
	}

	public function login(
		type : PermissionsType,
		permissions : Array<String>,
		onComplete : Void->Void,
		onCancel : Void->Void,
		onError : String->Void
	) {

		var fonComplete = function() {
			addTask(new CallTask(onComplete));
		}

		var fOnCancel = function() {
			addTask(new CallTask(onCancel));
		}

		var fOnError = function(error) {
			addTask(new CallStrTask(onError, error));
		}

		#if (android || ios)

		FacebookCFFI.setOnLoginSuccessCallback(fonComplete);
		FacebookCFFI.setOnLoginCancelCallback(fOnCancel);
		FacebookCFFI.setOnLoginErrorCallback(fOnError);
		FacebookCFFI.logInWithReadPermissions(permissions);
		//FacebookCFFI.logInWithLimited(permissions);

		#end
	}

	public function logout() {
		#if (android || iphone)
		FacebookCFFI.logout();
		#end
	}

	function prependSlash(str : String) : String {
		if (str.charAt(0)=="/") {
			return str;
		}
		return "/" + str;
	}

	public function get(
		resource : String,
		onComplete : Dynamic->Void = null,
		parameters : Map<String, String> = null,
		onError : Dynamic->Void = null
	) : Void {

		if (onComplete==null) {
			onComplete = function(s) {};
		}
		if (parameters==null) {
			parameters = new Map<String, String>();
		}
		if (onError==null) {
			onError = function(s) {};
		}
		parameters.set("redirect", "false");
		#if android
		FacebookCFFI.graphRequest(
			prependSlash(resource),
			parameters,
			"GET",
			function(x) {
				try { 
					var parsed = Json.parse(x);
					onComplete(parsed);
				} catch(error:String) { trace(error, x); }
			},
			function(x){
				try { 
					var parsed = Json.parse(x);
					onError(parsed);
				} catch(error:String) { trace(error, x); }
			}
		);
		#else
		parameters.set("access_token", accessToken);

		var headerMap:StringMap<String> = new StringMap();
		var parameterMap:StringMap<String> = new StringMap();
		
		IOSNetworking.httpRequest(
			"https://graph.facebook.com/v18.0"+prependSlash(resource)+"?access_token="+accessToken+"&fields="+parameters.get("fields"),
			"GET",
			headerMap,
			parameterMap,
			function (x) {
				try { 
					var parsed = Json.parse(x);
					onComplete(parsed);
				} catch(error:String) { trace(error, x); }
				},

			function (er) {
				onError("error");
			}
		);
		
		#end
	}

	public function setDebug()
	{
		#if (android || ios)
			FacebookCFFI.setDebug();
		#end
	}

	public function logEvent(eventName:String, jsonPayload:String)
	{
		#if (android || ios)
			FacebookCFFI.logEvent(eventName, jsonPayload);
		#end
	}

	public function setUserID(userID:String)
	{
		#if android
			FacebookCFFI.setUserID(userID);
		#end
	}

	public function trackPurchase(purchaseAmount:Float, currency:String, ?parameters:String)
	{
		#if android
			FacebookCFFI.trackPurchase(purchaseAmount, currency, parameters);
		#end
		#if ios
			FacebookCFFI.logPurchase(purchaseAmount, currency, parameters);
		#end
	}
}
