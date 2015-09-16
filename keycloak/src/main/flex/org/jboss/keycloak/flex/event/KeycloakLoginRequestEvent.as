/**
 * Created by christoferdutz on 14.09.15.
 */
package org.jboss.keycloak.flex.event {
import flash.events.Event;

public class KeycloakLoginRequestEvent extends Event {

    public static const LOGIN_REQUEST:String = "loginRequest";

    private var _username:String;
    private var _password:String;

    public function KeycloakLoginRequestEvent(type:String, username:String, password:String,
                                              bubbles:Boolean = true, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this._username = username;
        this._password = password;
    }

    public function get username():String {
        return _username;
    }

    public function get password():String {
        return _password;
    }

}
}
