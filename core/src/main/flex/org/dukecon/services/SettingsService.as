/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {

import flash.events.EventDispatcher;

import mx.resources.ResourceManager;

import nz.co.codec.flexorm.EntityManager;

import org.dukecon.events.SettingsChangedEvent;

import org.dukecon.model.Conference;
import org.dukecon.model.Language;
import org.dukecon.model.Settings;

[Event(name="settingsChanged", type="org.dukecon.events.SettingsChangedEvent")]
[ManagedEvents("settingsChanged")]
public class SettingsService extends EventDispatcher {

    private static var _selectedConferenceId:String;
    private static var _selectedLanguage:Language;

    private var em:EntityManager;
    private var settings:Settings;

    private var _installedLanguages:Array;

    public static function get selectedConferenceId():String {
        return _selectedConferenceId;
    }

    public static function get selectedLanguage():Language {
        return _selectedLanguage;
    }

    public function SettingsService() {
        em = EntityManager.instance;
    }

    public function set installedLanguages(installedLanguages:Array):void {
        _installedLanguages = installedLanguages;
    }

    public function set selectedConference(conference:Conference):void {
        settings.selectedConferenceId = (conference) ? conference.id : null;
        saveSettings();
        _selectedConferenceId = settings.selectedConferenceId;
        dispatchEvent(SettingsChangedEvent.createSettingsChangedEvent());
    }

    public function set selectedLanguage(language:Language):void {
        settings.selectedLanguageId = (language) ? language.id : null;
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

    public function loadSettings():void {
        // Load the settings and initialize the static properties.
        settings = em.load(Settings, "1") as Settings;
        if(!settings) {
            settings = new Settings();
            settings.id = "1";
            saveSettings();
        }
        _selectedConferenceId = settings.selectedConferenceId;
        _selectedLanguage = new Language();
        _selectedLanguage.id = settings.selectedLanguageId;
        _selectedLanguage.code = ResourceManager.getInstance().localeChain[0];
    }

    private function saveSettings():void {
        em.save(settings);
    }

}
}
