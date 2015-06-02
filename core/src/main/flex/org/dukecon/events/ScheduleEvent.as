/**
 * Created by christoferdutz on 15.05.15.
 */
package org.dukecon.events {
import flash.events.Event;

public class ScheduleEvent extends Event {

    public static var DAY_SELECTED:String = "daySelected";

    private var _day:String;

    public function ScheduleEvent(day:String, type:String, bubbles:Boolean = true, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this._day = day;
    }

    public function get day():String {
        return _day;
    }
}
}
