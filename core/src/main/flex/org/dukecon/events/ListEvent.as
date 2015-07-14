/**
 * Created by christoferdutz on 15.05.15.
 */
package org.dukecon.events {
import flash.events.Event;

public class ListEvent extends Event {

    public static var ITEM_SELECTED:String = "itemSelected";

    private var _data:*;

    public function ListEvent(data:*, type:String, bubbles:Boolean = true, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this._data = data;
    }

    public function get data():* {
        return _data;
    }
}
}
