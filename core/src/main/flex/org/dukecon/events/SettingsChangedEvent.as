/**
 * Created by christoferdutz on 15.05.15.
 */
package org.dukecon.events {
import flash.events.Event;

public class SettingsChangedEvent extends Event {

    public static var SETTINGS_CHANGED:String = "settingsChanged";

    public function SettingsChangedEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }

}
}
