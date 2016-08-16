/**
 * Created by christoferdutz on 15.05.15.
 */
package org.dukecon.events {
import flash.events.Event;

public class ConferenceDataChangedEvent extends Event {

    public static var CONFERENCE_DATA_CHANGED:String = "conferenceDataChanged";

    public function ConferenceDataChangedEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }

    public static function createConferenceDataChangedEvent():ConferenceDataChangedEvent {
        return new ConferenceDataChangedEvent(CONFERENCE_DATA_CHANGED);
    }


}
}
