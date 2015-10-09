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

    public function getIconForTrack(id:String):Class {
        if (id) {
            switch (id) {
                case "1":
                    return track_jvm_languages;
                case "2":
                    return track_microservices;
                case "3":
                    return track_architecture;
                case "4":
                    return track_internet_of_things;
                case "5":
                    return track_newcomer;
                case "6":
                    return track_ide_tools;
                case "7":
                    return track_enterprise_java_cloud;
                case "8":
                    return track_frontend_mobile;
            }
            trace("Couldn't find icon for: " + id);
        }
        return null;
    }

}
}

