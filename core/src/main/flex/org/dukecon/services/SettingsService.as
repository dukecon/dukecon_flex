/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {
import mx.resources.ResourceManager;

import nz.co.codec.flexorm.EntityManager;

import mx.collections.ArrayCollection;

import org.dukecon.model.Conference;
import org.dukecon.model.Language;
import org.dukecon.model.Settings;

public class SettingsService {

    private static var _selectedConference:Conference;
    private static var _selectedLanguage:Language;

    private var em:EntityManager;
    private var settings:Settings;

    private var _installedLanguages:Array;

    public static function get selectedConference():Conference {
        if(!_selectedConference) {
            _selectedConference = new Conference();
            _selectedConference.id = "499959";
        }

        return _selectedConference;
    }

    public static function get selectedLanguage():Language {
        if(!_selectedLanguage) {
            _selectedLanguage = new Language();
            _selectedLanguage.code = ResourceManager.getInstance().localeChain[0];
        }

        return _selectedLanguage;
    }

    public function SettingsService() {
        em = EntityManager.instance;
    }

    [Init]
    public function init():void {
        loadSettings();
    }

    public function set installedLanguages(installedLanguages:Array):void {
        _installedLanguages = installedLanguages;
    }

    public function set selectedConference(conference:Conference):void {
        settings.selectedConferenceId = conference.id;
        saveSettings();
        _selectedConference = conference;
    }

    public function set selectedLanguage(language:Language):void {
        settings.selectedLanguageId = language.id;
        saveSettings();
        _selectedLanguage = language;
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

    private function loadSettings():void {
        // TODO: Load the settings and initialize the static properties.
/*        var settingss:ArrayCollection = em.findAll(Settings);
        settings = settingss[0];
        trace(settingss);*/
    }

    private function saveSettings():void {
        em.save(settings);
    }

}
}
