/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {

import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;
import flash.utils.getQualifiedClassName;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.resources.ResourceManager;

import org.dukecon.events.SettingsChangedEvent;
import org.dukecon.model.Settings;

[Event(name="settingsChanged", type="org.dukecon.events.SettingsChangedEvent")]
[ManagedEvents("settingsChanged")]
public class SettingsService extends EventDispatcher {

    protected static var log:ILogger = Log.getLogger(getQualifiedClassName(SettingsService).replace("::"));

    private var settingsSharedObject:SharedObject;

    private var _installedLanguages:Array;

    public function SettingsService() {
        settingsSharedObject = SharedObject.getLocal("dukecon-settings");
        if(!settingsSharedObject.data.settings) {
            var settings:Settings = new Settings();
            settings.selectedLanguageId = ResourceManager.getInstance().localeChain[0];
            settingsSharedObject.data.settings = settings;
        } else {
            ResourceManager.getInstance().localeChain =
                    [Settings(settingsSharedObject.data.settings).selectedLanguageId];
        }
        dispatchEvent(SettingsChangedEvent.createSettingsChangedEvent());
    }

    public function set installedLanguages(installedLanguages:Array):void {
        _installedLanguages = installedLanguages;
    }

    public function set selectedConferenceId(conferenceId:String):void {
        settingsSharedObject.data.settings.selectedConferenceId = conferenceId;
        saveSettings();
        dispatchEvent(SettingsChangedEvent.createSettingsChangedEvent());
    }

    [Bindable("settingsChanged")]
    public function get selectedConferenceId():String {
        return Settings(settingsSharedObject.data.settings).selectedConferenceId;
    }

    public function set selectedLanguageId(language:String):void {
        Settings(settingsSharedObject.data.settings).selectedLanguageId = language;
        ResourceManager.getInstance().localeChain = [language];
        saveSettings();
        dispatchEvent(SettingsChangedEvent.createSettingsChangedEvent());
    }

    [Bindable("settingsChanged")]
    public function get selectedLanguageId():String {
        return Settings(settingsSharedObject.data.settings).selectedLanguageId;
    }

    private function saveSettings():void {
        var flushStatus:String = null;
        try {
            flushStatus = settingsSharedObject.flush(10000);
        } catch (error:Error) {
            log.error("Error writing shared object to disk.", error);
        }
        if (flushStatus != null) {
            switch (flushStatus) {
                case SharedObjectFlushStatus.PENDING:
                    log.info("Requesting permission to save object...\n");
                    settingsSharedObject.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                    break;
                case SharedObjectFlushStatus.FLUSHED:
                    log.info("Value flushed to disk.");
                    break;
            }
        }
    }

    private function onFlushStatus(event:NetStatusEvent):void {
        switch (event.info.code) {
            case "SharedObject.Flush.Success":
                log.info("User granted permission -- value saved.");
                break;
            case "SharedObject.Flush.Failed":
                log.info("User denied permission -- value not saved.");
                break;
        }
        settingsSharedObject.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
    }

}
}
