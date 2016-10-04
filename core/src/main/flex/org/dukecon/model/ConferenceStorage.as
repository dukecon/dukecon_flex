/**
 * Created by christoferdutz on 26.09.16.
 */
package org.dukecon.model {
import mx.collections.ArrayCollection;

import spark.collections.Sort;

import spark.collections.SortField;

[RemoteClass]
public class ConferenceStorage {

    private var _id:String;
    private var _conference:Conference;

    private var _days:ArrayCollection;

    private var _streamIndex:Object;
    private var _locationIndex:Object;
    private var _eventTypeIndex:Object;
    private var _languageIndex:Object;
    private var _audienceIndex:Object;
    private var _speakerIndex:Object;
    private var _dayIndex:Object;

    public function ConferenceStorage() {
    }

    public function get id():String {
        return _id;
    }

    public function set id(value:String):void {
        _id = value;
    }

    public function get conference():Conference {
        return _conference;
    }

    public function set conference(value:Conference):void {
        _conference = value;
    }

    public function get days():ArrayCollection {
        return _days;
    }

    public function set days(value:ArrayCollection):void {
        _days = value;
    }

    public function get firstDay():Date {
        // Sort the days
        var orderSortField:SortField = new SortField();
        var locationSort:Sort = new Sort();
        locationSort.fields = [orderSortField];
        _days.sort = locationSort;
        _days.refresh();

        var matches:Array = String(_days[0]).match(/(\d\d\d\d)-(\d\d)-(\d\d)/);
        return new Date(int(matches[1]), int(matches[2]) - 1, int(matches[3]));
    }

    public function get lastDay():Date {
        // Sort the days
        var orderSortField:SortField = new SortField();
        var locationSort:Sort = new Sort();
        locationSort.fields = [orderSortField];
        _days.sort = locationSort;
        _days.refresh();

        var matches:Array = String(_days[_days.length - 1]).match(/(\d\d\d\d)-(\d\d)-(\d\d)/);
        return new Date(int(matches[1]), int(matches[2]) - 1, int(matches[3]));
    }

    public function get streamIndex():Object {
        return _streamIndex;
    }

    public function set streamIndex(value:Object):void {
        _streamIndex = value;
    }

    public function get locationIndex():Object {
        return _locationIndex;
    }

    public function set locationIndex(value:Object):void {
        _locationIndex = value;
    }

    public function get eventTypeIndex():Object {
        return _eventTypeIndex;
    }

    public function set eventTypeIndex(value:Object):void {
        _eventTypeIndex = value;
    }

    public function get languageIndex():Object {
        return _languageIndex;
    }

    public function set languageIndex(value:Object):void {
        _languageIndex = value;
    }

    public function get audienceIndex():Object {
        return _audienceIndex;
    }

    public function set audienceIndex(value:Object):void {
        _audienceIndex = value;
    }

    public function get speakerIndex():Object {
        return _speakerIndex;
    }

    public function set speakerIndex(value:Object):void {
        _speakerIndex = value;
    }

    public function get dayIndex():Object {
        return _dayIndex;
    }

    public function set dayIndex(value:Object):void {
        _dayIndex = value;
    }
}
}
