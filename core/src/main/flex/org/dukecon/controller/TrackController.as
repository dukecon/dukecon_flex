/**
 * Created by christoferdutz on 22.05.15.
 */
package org.dukecon.controller {
public class TrackController {

    private static var _instance:TrackController;

    public static function get instance():TrackController {
        if(!_instance) {
            _instance = new TrackController(new SingletonEnforcer());
        }
        return _instance;
    }

    [Embed(source="/tracks/architektur.svg")]
    [Bindable]
    protected static var architektur:Class;

    [Embed(source="/tracks/cloud-and-big-data.svg")]
    [Bindable]
    protected static var cloudAndBigData:Class;

    [Embed(source="/tracks/core-java.svg")]
    [Bindable]
    protected static var coreJava:Class;

    [Embed(source="/tracks/enterprise-java.svg")]
    [Bindable]
    protected static var enterpriseJava:Class;

    [Embed(source="/tracks/frontend.svg")]
    [Bindable]
    protected static var frontend:Class;

    [Embed(source="/tracks/internet-of-things.svg")]
    [Bindable]
    protected static var internetOfThings:Class;

    [Embed(source="/tracks/mobile.svg")]
    [Bindable]
    protected static var mobile:Class;

    [Embed(source="/tracks/security.svg")]
    [Bindable]
    protected static var secutiry:Class;

    [Embed(source="/tracks/jvm-languages.svg")]
    [Bindable]
    protected static var jvmLanguages:Class;

    [Embed(source="/tracks/ides-and-tools.svg")]
    [Bindable]
    protected static var idesAndTools:Class;

    public function TrackController(enforcer:SingletonEnforcer) {
    }

    public function getIconForTrack(trackName:String):Class {
        var trackCode:String = trackName.toLowerCase();
        while(trackCode.indexOf(" ") != -1) {
            trackCode = trackCode.replace(" ", "-");
        }
        switch (trackCode) {
            case "architektur":
                return architektur;
            case "cloud-and-big-data":
                return cloudAndBigData;
            case "core-java":
                return coreJava;
            case "enterprise-java":
                return enterpriseJava;
            case "frontend":
                return frontend;
            case "internet-of-things":
                return internetOfThings;
            case "mobile":
                return mobile;
            case "security":
                return secutiry;
            case "jvm-languages":
                return jvmLanguages;
            case "ides-and-tools":
                return idesAndTools;
        }
        trace("Couldn't find icon for: " + trackCode);
        return null;
    }

}
}
class SingletonEnforcer{}

