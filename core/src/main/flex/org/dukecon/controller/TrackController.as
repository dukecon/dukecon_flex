/**
 * Created by christoferdutz on 22.05.15.
 */
package org.dukecon.controller {
public class TrackController {

    [Embed(source="/tracks/track_architecture.jpg")]
    [Bindable]
    protected static var track_architecture:Class;

    [Embed(source="/tracks/track_enterprise-java-cloud.jpg")]
    [Bindable]
    protected static var track_enterprise_java_cloud:Class;

    [Embed(source="/tracks/track_frontend-mobile.jpg")]
    [Bindable]
    protected static var track_frontend_mobile:Class;

    [Embed(source="/tracks/track_ide-tools.jpg")]
    [Bindable]
    protected static var track_ide_tools:Class;

    [Embed(source="/tracks/track_internet-of-things.jpg")]
    [Bindable]
    protected static var track_internet_of_things:Class;

    [Embed(source="/tracks/track_jvm-languages.jpg")]
    [Bindable]
    protected static var track_jvm_languages:Class;

    [Embed(source="/tracks/track_microservices.jpg")]
    [Bindable]
    protected static var track_microservices:Class;

    [Embed(source="/tracks/track_newcomer.jpg")]
    [Bindable]
    protected static var track_newcomer:Class;

    public function TrackController() {
    }

    public function getIconForTrack(trackName:String):Class {
        if (trackName) {
            switch (trackName) {
                case "Core Java & JVM basierte Sprachen":
                    return track_jvm_languages;
                case "Container & Microservices":
                    return track_microservices;
                case "Architektur & Sicherheit":
                    return track_architecture;
                case "Internet der Dinge":
                    return track_internet_of_things;
                case "Newcomer":
                    return track_newcomer;
                case "IDEs & Tools":
                    return track_ide_tools;
                case "Enterprise Java & Cloud":
                    return track_enterprise_java_cloud;
                case "Frontend & Mobile":
                    return track_frontend_mobile;
            }
            trace("Couldn't find icon for: " + trackName);
        }
        return null;
    }

    private function getColorForTrack(trackName:String):uint {
        if (trackName) {
            var trackCode:String = trackName.toLowerCase();
            while (trackCode.indexOf(" ") != -1) {
                trackCode = trackCode.replace(" ", "-");
            }
            switch (trackCode) {
                case "Core Java & JVM basierte Sprachen":
                case "Container & Microservices":
                case "Architektur & Sicherheit":
                case "Internet der Dinge":
                case "Newcomer":
                case "IDEs & Tools":
                case "Enterprise Java & Cloud":
                case "Frontend & Mobile":
            }
            trace("Couldn't find color for: " + trackCode);
        }
        return null;
    }

}
}

