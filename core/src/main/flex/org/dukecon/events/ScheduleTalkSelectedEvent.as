/**
 * Created by christoferdutz on 15.05.15.
 */
package org.dukecon.events {
import flash.events.Event;

import org.dukecon.model.Talk;

public class ScheduleTalkSelectedEvent extends Event {

    public static var TALK_SELECTED:String = "talkSelected";

    private var _data:Talk;

    public function ScheduleTalkSelectedEvent(data:Talk, type:String, bubbles:Boolean = true, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this._data = data;
    }

    public function get talk():Talk {
        return _data;
    }
}
}
