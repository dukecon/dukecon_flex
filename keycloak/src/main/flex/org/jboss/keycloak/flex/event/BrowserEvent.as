/**
 * Created by christoferdutz on 14.09.15.
 */
package org.jboss.keycloak.flex.event {
import flash.events.Event;

public class BrowserEvent extends Event {

    public static const LOCATION_CHANGED:String = "locationChanged";

    private var _oldUrl:String;
    private var _newUrl:String;

    public function BrowserEvent(type:String, oldUrl:String, newUrl:String,
                                 bubbles:Boolean = true, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this._oldUrl = oldUrl;
        this._newUrl = newUrl;
    }

    public function get oldUrl():String {
        return _oldUrl;
    }

    public function get newUrl():String {
        return _newUrl;
    }
}
}
