/**
 * Created by christoferdutz on 03.08.16.
 */
package org.dukecon.fpa {
public class FpaField {

    private var _name:String;
    private var _type:Class;
    private var _dbName:String;

    public function FpaField() {
    }

    public function get name():String {
        return _name;
    }

    public function set name(value:String):void {
        _name = value;
    }

    public function get type():Class {
        return _type;
    }

    public function set type(value:Class):void {
        _type = value;
    }

    public function get dbName():String {
        return _dbName;
    }

    public function set dbName(value:String):void {
        _dbName = value;
    }
}
}
