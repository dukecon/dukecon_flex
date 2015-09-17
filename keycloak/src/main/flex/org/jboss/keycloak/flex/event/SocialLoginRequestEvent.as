/**
 * Created by christoferdutz on 14.09.15.
 */
package org.jboss.keycloak.flex.event {
import flash.events.Event;

public class SocialLoginRequestEvent extends Event {

    public static const SOCIAL_PROVIDER_LOGIN_REQUEST:String = "socialProviderLoginRequest";

    private var _providerName:String;
    private var _providerUrl:String;

    public function SocialLoginRequestEvent(type:String, providerName:String, providerUrl:String,
                                            bubbles:Boolean = true, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this._providerName = providerName;
        this._providerUrl = providerUrl;
    }

    public function get providerName():String {
        return _providerName;
    }

    public function get providerUrl():String {
        return _providerUrl;
    }

}
}
