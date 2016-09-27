/**
 * Created by christoferdutz on 25.08.16.
 */
package org.dukecon.model {

[RemoteClass]
public class Settings {

    private var _selectedConferenceId:String;
    private var _selectedLanguageId:String;

    public function Settings() {
    }

    public function get selectedConferenceId():String {
        return _selectedConferenceId;
    }

    public function set selectedConferenceId(value:String):void {
        _selectedConferenceId = value;
    }

    public function get selectedLanguageId():String {
        return _selectedLanguageId;
    }

    public function set selectedLanguageId(value:String):void {
        _selectedLanguageId = value;
    }

}
}
