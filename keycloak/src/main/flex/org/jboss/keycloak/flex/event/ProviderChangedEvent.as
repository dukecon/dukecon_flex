/**
 * Created by christoferdutz on 27.02.16.
 */
package org.jboss.keycloak.flex.event {
import flash.events.Event;

public class ProviderChangedEvent extends Event {

    public static const PROVIDER_CHANGED:String = "providerChanged";

    private var _provider:String;
    
    public function ProviderChangedEvent(type:String, provider:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        _provider = provider;
    }
    
    public function get provider():String {
        return _provider;
    }
}
}
