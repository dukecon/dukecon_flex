/**
 * Created by christoferdutz on 22.05.15.
 */
package org.dukecon.controller {
public class StreamController {

    [Embed(source="/streams/stream_architecture.jpg")]
    [Bindable]
    protected static var stream_architecture:Class;

    [Embed(source="/streams/stream_enterprise-java-cloud.jpg")]
    [Bindable]
    protected static var stream_enterprise_java_cloud:Class;

    [Embed(source="/streams/stream_frontend-mobile.jpg")]
    [Bindable]
    protected static var stream_frontend_mobile:Class;

    [Embed(source="/streams/stream_ide-tools.jpg")]
    [Bindable]
    protected static var stream_ide_tools:Class;

    [Embed(source="/streams/stream_internet-of-things.jpg")]
    [Bindable]
    protected static var stream_internet_of_things:Class;

    [Embed(source="/streams/stream_jvm-languages.jpg")]
    [Bindable]
    protected static var stream_jvm_languages:Class;

    [Embed(source="/streams/stream_microservices.jpg")]
    [Bindable]
    protected static var stream_microservices:Class;

    [Embed(source="/streams/stream_newcomer.jpg")]
    [Bindable]
    protected static var stream_newcomer:Class;

    [Embed(source="/streams/stream_unknown.jpg")]
    [Bindable]
    protected static var stream_unknown:Class;

    public function StreamController() {
    }

    public function getIconForStream(id:String):Class {
        if (id) {
            switch (id) {
                case "1":
                    return stream_jvm_languages;
                case "2":
                    return stream_microservices;
                case "3":
                    return stream_architecture;
                case "4":
                    return stream_internet_of_things;
                case "5":
                    return stream_newcomer;
                case "6":
                    return stream_ide_tools;
                case "7":
                    return stream_enterprise_java_cloud;
                case "8":
                    return stream_frontend_mobile;
                default:
                    return stream_unknown;
            }
        }
        return null;
    }

}
}

