/**
 * Created by christoferdutz on 15.05.15.
 */
package org.dukecon.events {
import flash.events.Event;

public class UserPreferenceDataChangedEvent extends Event {

    public static var USER_PREFERENCE_DATA_CHANGED:String = "userPreferenceDataChanged";

    public function UserPreferenceDataChangedEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }

}
}
