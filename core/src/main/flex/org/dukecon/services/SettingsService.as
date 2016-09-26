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
import org.dukecon.model.Conference;
import org.dukecon.model.Language;
import org.dukecon.model.Settings;

[Event(name="settingsChanged", type="org.dukecon.events.SettingsChangedEvent")]
[ManagedEvents("settingsChanged")]
public class SettingsService extends EventDispatcher {

    protected static var log:ILogger = Log.getLogger(getQualifiedClassName(SettingsService).replace("::"));

    private static var _selectedConferenceId:String;
    private static var _selectedLanguage:Language;

    private var settingsSharedObject:SharedObject;

    private var _installedLanguages:Array;

    public static function get selectedConferenceId():String {
        return _selectedConferenceId;
    }

    public static function get selectedLanguage():Language {
        return _selectedLanguage;
    }

    public function SettingsService() {
        settingsSharedObject = SharedObject.getLocal("dukecon-settings");
        if(!settingsSharedObject.data.settings) {
            settingsSharedObject.data.settings = new Settings();
        }
        _selectedConferenceId = settingsSharedObject.data.settings.selectedConferenceId;
        _selectedLanguage = new Language();
        _selectedLanguage.id = settingsSharedObject.data.settings.selectedLanguageId;
        _selectedLanguage.code = ResourceManager.getInstance().localeChain[0];
    }

    public function set installedLanguages(installedLanguages:Array):void {
        _installedLanguages = installedLanguages;
    }

    public function set selectedConference(conference:Conference):void {
        settingsSharedObject.data.settings.selectedConferenceId = (conference) ? conference.id : null;
        saveSettings();
        _selectedConferenceId = settingsSharedObject.data.settings.selectedConferenceId;
        dispatchEvent(SettingsChangedEvent.createSettingsChangedEvent());
    }

    public function set selectedLanguage(language:Language):void {
        settingsSharedObject.data.settings.selectedLanguageId = (language) ? language.id : null;
        saveSettings();
        _selectedLanguage = language;
        dispatchEvent(SettingsChangedEvent.createSettingsChangedEvent());
    }

    private function getResourceLanguageCode(language:Language):String {
        if(language) {
            for each(var installedLanguage:String in _installedLanguages) {
                if(installedLanguage == language.code) {
                    return language.code;
                }
                if(installedLanguage.indexOf(language.code + "_") == 0) {
                    return installedLanguage;
                }
            }
        }
        return _installedLanguages[0];
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
