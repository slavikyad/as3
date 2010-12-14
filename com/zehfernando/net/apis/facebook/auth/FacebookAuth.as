package com.zehfernando.net.apis.facebook.auth {

	import com.zehfernando.net.apis.facebook.FacebookConstants;
	import com.zehfernando.net.apis.facebook.events.FacebookAuthEvent;
	import com.zehfernando.utils.HTMLUtils;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.LocalConnection;
	/**
	 * @author zeh
	 */
	public class FacebookAuth {

		// http://developers.facebook.com/docs/authentication/javascript
		
		// Move this all to a more generic OAuth class?
		
		// Properties
		public static var appId:String;
		public static var redirectURL:String;
		
		protected static var localConnection:LocalConnection;
		protected static var _accessToken:String;
		
		protected static var _loggedIn:Boolean;
		
		protected static var eventDispatcher:EventDispatcher = new EventDispatcher();
		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookAuth() {
		}
			
		// ================================================================================================================
		// EVENT DISPATCHER INTERFACE -------------------------------------------------------------------------------------
		
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false): void {
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public static function dispatchEvent(event:Event): Boolean {
			return eventDispatcher.dispatchEvent(event);
		}

		public static function hasEventListener(type:String): Boolean {
			return eventDispatcher.hasEventListener(type);
		}

		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false): void {
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}

		public static function willTrigger(type:String): Boolean {
			return eventDispatcher.willTrigger(type);
		}
		
		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------
		
		public static function onLoginSuccessLC(__accessToken:String): void {
			trace("FacebookAuth :: Login success with access token " + __accessToken);
			_accessToken = __accessToken;
			_loggedIn = true;
			dispatchEvent(new FacebookAuthEvent(FacebookAuthEvent.LOG_IN_SUCCESS));
			localConnection.close();
		}

		public static function onLoginErrorLC(__errorReason:String, __errorType:String, __errorDescription:String): void {
			trace("FacebookAuth :: Login error with reason ["+__errorReason+"], type ["+__errorType+"], description ["+__errorDescription+"]");
			_loggedIn = false;
			dispatchEvent(new FacebookAuthEvent(FacebookAuthEvent.LOG_IN_ERROR));
			localConnection.close();
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function login(): void {
			// Open the popup window asking for login permission
			
			localConnection = new LocalConnection();
			localConnection.allowDomain("*");
			localConnection.client = {onLoginSuccessLC:onLoginSuccessLC, onLoginErrorLC:onLoginErrorLC};
			try {
				localConnection.connect("_zFacebookAuthConn");
			} catch (e:Error) {
				trace("FacebookAuth :: Login failed because it's already connected!");
			}

			var url:String = FacebookConstants.AUTHORIZE_URL.split(FacebookConstants.PARAMETER_APP_ID).join(appId).split(FacebookConstants.PARAMETER_REDIRECT_URL).join(redirectURL);
			HTMLUtils.openPopup(url);

			// https://graph.facebook.com/oauth/authorize?client_id=147149585329358&redirect_uri=http://www.facebook.com/connect/login_success.html&type=user_agent&display=popup
			// Goes to
			// http://www.facebook.com/connect/login_success.html#access_token=147149585329358|2.0FiQGOUJJO4c_Cn9ldS2sw__.3600.1287158400-711322444|DWZFLTJtB48ilCs73xp8uu1jn4E&expires_in=4997
			
			// https://graph.facebook.com/oauth/authorize?client_id=147149585329358&redirect_uri=http://fakehost.com/SANDBOX/deploy/fb_login_success.html&type=user_agent&display=popup
			// Goes to
			// http://fakehost.com/SANDBOX/deploy/fb_login_success.html#access_token=147149585329358|2.0FiQGOUJJO4c_Cn9ldS2sw__.3600.1287158400-711322444|DWZFLTJtB48ilCs73xp8uu1jn4E&expires_in=3677
			// Or
			// http://fakehost.com/SANDBOX/deploy/fb_login_success.html?error_reason=user_denied&error=access_denied&error_description=The+user+denied+your+request.

			// https://graph.facebook.com/me?access_token=2227470867%7C2.ymbE61jcLXs8V0LybrlzPA__.3600.1287158400-711322444%7Cz8rYDB_GlfbSaEiJ0-3j6MZxBCg
			// https://graph.facebook.com/me/friends?access_token=2227470867|2.ymbE61jcLXs8V0LybrlzPA__.3600.1287158400-711322444|z8rYDB_GlfbSaEiJ0-3j6MZxBCg
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public static function get accessToken(): String {
			return _accessToken;
		}

		public static function get loggedIn(): Boolean {
			return _loggedIn;
		}

	}
}