package org.dukecon.controller {

import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;

import org.dukecon.events.SettingsChangedEvent;

[Event(type="org.dukecon.events.SettingsChangedEvent", name="settingsChanged")]
public class SettingsController extends EventDispatcher {

    private var settings:SharedObject;

    public function SettingsController() {
        settings = SharedObject.getLocal("settings");
    }

    [Bindable("settingsChanged")]
    public function get selectedLanguage():String {
        if (settings.data && settings.data.savedValue) {
            return settings.data.savedValue["language"];
        }
        return "en_US";
    }

    public function set selectedLanguage(language:String):void {
        if (!settings.data.savedValue) {
            settings.data.savedValue = {};
        }
        settings.data.savedValue["language"] = language;
        flushSharedObject(settings);
        dispatchEvent(new SettingsChangedEvent(SettingsChangedEvent.SETTINGS_CHANGED));
    }

    protected function flushSharedObject(so:SharedObject):void {
        var flushStatus:String = null;
        try {
            flushStatus = so.flush(10000);
        } catch (error:Error) {
            trace("Error...Could not write SharedObject to disk\n");
        }
        if (flushStatus != null) {
            switch (flushStatus) {
                case SharedObjectFlushStatus.PENDING:
                    trace("Requesting permission to save object...\n");
                    so.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                    break;
                case SharedObjectFlushStatus.FLUSHED:
                    trace("Value flushed to disk.\n");
                    break;
            }
        }
    }

    private function onFlushStatus(event:NetStatusEvent):void {
        trace("User closed permission dialog...\n");
        switch (event.info.code) {
            case "SharedObject.Flush.Success":
                trace("User granted permission -- value saved.\n");
                break;
            case "SharedObject.Flush.Failed":
                trace("User denied permission -- value not saved.\n");
                break;
        }
    }

}
}
