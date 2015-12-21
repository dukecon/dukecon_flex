/**
 * Created by christoferdutz on 28.10.15.
 */
package org.dukecon.components.model {
public class ScheduleItemGroup {

    private var _groupName:String;
    private var _items:Array;

    public function ScheduleItemGroup() {
        super();
    }

    public function get groupName():String {
        return _groupName;
    }

    public function set groupName(value:String):void {
        _groupName = value;
    }

    public function get items():Array {
        return _items;
    }

    public function addItem(item:ScheduleItem):void {
        if(!_items) {
            _items = [];
        }
        _items.push(item);
    }

}
}
