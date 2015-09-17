/**
 * Created by christoferdutz on 14.09.15.
 */
package org.jboss.keycloak.flex.event {
import flash.events.Event;

public class KeycloakLoginEvent extends Event {

    public static const SHOW_LOGIN_SCREEN:String = "showLoginScreen";

    private var _socialProviders:Object;
    private var _feedbackMessage:String;
    private var _keycloakLoginCallback:Function;
    private var _socialLoginCallback:Function;

    public function KeycloakLoginEvent(type:String, socialProviders:Object, feedbackMessage:String,
                                       keycloakLoginCallback:Function, socialLoginCallback:Function,
                                       bubbles:Boolean = true, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this._socialProviders = socialProviders;
        this._feedbackMessage = feedbackMessage;
        this._keycloakLoginCallback = keycloakLoginCallback;
        this._socialLoginCallback = socialLoginCallback;
    }

    public function get socialProviders():Object {
        return _socialProviders;
    }

    public function get feedbackMessage():String {
        return _feedbackMessage;
    }

    public function get keycloakLoginCallback():Function {
        return _keycloakLoginCallback;
    }

    public function get socialLoginCallback():Function {
        return _socialLoginCallback;
    }

}
}
