/**
 * Created by christoferdutz on 28.10.15.
 */
package org.dukecon.components.model {
public class ScheduleItem {

    private var _startTime:Date;

    private var _endTime:Date;

    public function ScheduleItem() {
        super();
    }

    public function get startTime():Date {
        return _startTime;
    }

    public function set startTime(value:Date):void {
        _startTime = value;
    }

    public function get endTime():Date {
        return _endTime;
    }

    public function set endTime(value:Date):void {
        _endTime = value;
    }

}
}
