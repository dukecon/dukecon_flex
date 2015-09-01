/**
 * Created by christoferdutz on 15.05.15.
 */
package org.dukecon.events {
import flash.events.Event;

public class LoginChangedEvent extends Event {

    public static var USER_LOGGED_IN:String = "userLoggedIn";
    public static var USER_LOGGED_OUT:String = "userLoggedOut";
    public static var USER_LOGIN_FAILURE:String = "userLoginFailure";

    private var _username:String;
    private var _accessToken:String;

    public function LoginChangedEvent(type:String, username:String = null, accessToken:String = null,
                                      bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this._username = username;
        this._accessToken = accessToken;
    }

    public function get username():String {
        return _username;
    }

    public function get accessToken():String {
        return _accessToken;
    }
}
}
