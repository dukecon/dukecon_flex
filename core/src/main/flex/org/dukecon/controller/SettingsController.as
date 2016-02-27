package org.dukecon.controller {

import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;
import flash.utils.getQualifiedClassName;

import mx.logging.ILogger;
import mx.logging.Log;

import mx.resources.ResourceManager;

import org.dukecon.events.SettingsChangedEvent;

[Event(type="org.dukecon.events.SettingsChangedEvent", name="settingsChanged")]
[ManagedEvents("settingsChanged")]
public class SettingsController extends EventDispatcher {

    protected static var log:ILogger = Log.getLogger(getQualifiedClassName(SettingsController).replace("::", "."));

    private var settings:SharedObject;

    public function SettingsController() {
        settings = SharedObject.getLocal("settings");

        ResourceManager.getInstance().localeChain = [selectedLanguage];
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

    [Bindable("settingsChanged")]
    public function get serverAccount():String {
        if (settings.data && settings.data.savedValue) {
            return settings.data.savedValue["serverAccount"];
        }
        return null;
    }

    public function set serverAccount(serverAccount:String):void {
        if (!settings.data.savedValue) {
            settings.data.savedValue = {};
        }
        settings.data.savedValue["serverAccount"] = serverAccount;
        flushSharedObject(settings);
        dispatchEvent(new SettingsChangedEvent(SettingsChangedEvent.SETTINGS_CHANGED));
    }

    protected function flushSharedObject(so:SharedObject):void {
        var flushStatus:String = null;
        try {
            flushStatus = so.flush(10000);
        } catch (error:Error) {
            log.error("Error...Could not write SharedObject to disk\n");
        }
        if (flushStatus != null) {
            switch (flushStatus) {
                case SharedObjectFlushStatus.PENDING:
                    log.info("Requesting permission to save object...\n");
                    so.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                    break;
                case SharedObjectFlushStatus.FLUSHED:
                    log.info("Value flushed to disk.\n");
                    break;
            }
        }
    }

    private function onFlushStatus(event:NetStatusEvent):void {
        log.debug("User closed permission dialog...\n");
        switch (event.info.code) {
            case "SharedObject.Flush.Success":
                log.info("User granted permission -- value saved.\n");
                break;
            case "SharedObject.Flush.Failed":
                log.warn("User denied permission -- value not saved.\n");
                break;
        }
    }

}
}
