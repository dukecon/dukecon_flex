/**
 * Created by christoferdutz on 14.09.15.
 */
package org.jboss.keycloak.flex.event {
import flash.events.Event;

public class SocialLoginEvent extends Event {

    public static const SHOW_SOCIAL_LOGIN_SCREEN:String = "showSocialLoginScreen";

    private var _keycloakHost:String;
    private var _url:String;
    private var _socialLoginCallback:Function;

    public function SocialLoginEvent(type:String, keycloakHost:String, url:String, socialLoginCallback:Function,
                                     bubbles:Boolean = true, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this._keycloakHost = keycloakHost;
        this._url = url;
        this._socialLoginCallback = socialLoginCallback;
    }

    public function get keycloakHost():String {
        return _keycloakHost;
    }

    public function get url():String {
        return _url;
    }

    public function get socialLoginCallback():Function {
        return _socialLoginCallback;
    }

}
}
