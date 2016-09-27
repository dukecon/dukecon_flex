/**
 * Created by christoferdutz on 24.08.16.
 */
package org.dukecon.services {
import flash.events.NetStatusEvent;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;
import flash.utils.ByteArray;
import flash.utils.getQualifiedClassName;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

public class ResourceService {

    protected static var log:ILogger = Log.getLogger(getQualifiedClassName(ConferenceService).replace("::"));

    [Embed(source="/speakers/default-speaker.jpg", mimeType="application/octet-stream")]
    public var defaultSpeaker:Class;

    private var service:RemoteObject;

    [Inject]
    public var serverConnection:ServerConnection;
    [Inject]
    public var settingsService:SettingsService;

    private var resourcesSharedObject:SharedObject;

    public function ResourceService() {
        service = new RemoteObject("resourceService");
        resourcesSharedObject = SharedObject.getLocal("dukecon-resources");
    }

    [Init]
    public function init():void {
        // Prepare the remote service.
        service.channelSet = serverConnection.connection;

        service.getResourcesForConference.addEventListener(ResultEvent.RESULT, onGetResourcesForConferenceResult);
        service.addEventListener(FaultEvent.FAULT, onFault);

        if(!resourcesSharedObject.data["conferenceResources"]) {
            update();
        }
    }

    public function update():void {
        log.info("Updating conferences");
        service.getResourcesForConference(settingsService.selectedConferenceId);
    }

    public function getIconForConference(conferenceId:String):ByteArray {
        return null;
    }

    public function getIconForLocation(locationId:String):ByteArray {
        if(resourcesSharedObject.data["conferenceResources"] &&
                resourcesSharedObject.data.conferenceResources["locations"]) {
            return resourcesSharedObject.data.conferenceResources.locations[locationId];
        }
        return null;
    }

    public function getMapForLocation(locationId:String):ByteArray {
        if(resourcesSharedObject.data["conferenceResources"] &&
                resourcesSharedObject.data.conferenceResources["locationMaps"]) {
            return resourcesSharedObject.data.conferenceResources.locationMaps[locationId];
        }
        return null;
    }

    public function getIconForStream(streamId:String):ByteArray {
        if(resourcesSharedObject.data["conferenceResources"] &&
                resourcesSharedObject.data.conferenceResources["streams"]) {
            return resourcesSharedObject.data.conferenceResources.streams[streamId];
        }
        return null;
    }

    public function getIconForLanguage(languageId:String):ByteArray {
        if(resourcesSharedObject.data["conferenceResources"] &&
                resourcesSharedObject.data.conferenceResources["languages"]) {
            return resourcesSharedObject.data.conferenceResources.languages[languageId];
        }
        return null;
    }

    public function getIconForSpeaker(speakerId:String):ByteArray {
        if(resourcesSharedObject.data["conferenceResources"] &&
                resourcesSharedObject.data.conferenceResources["speakers"]) {
            return resourcesSharedObject.data.conferenceResources.speakers[speakerId];
        }
        return new defaultSpeaker();
    }

    private function onGetResourcesForConferenceResult(resultEvent:ResultEvent):void {
        log.info("Got response");
        resourcesSharedObject.data.conferenceResources = resultEvent.result;

        var flushStatus:String = null;
        try {
            flushStatus = resourcesSharedObject.flush(10000);
        } catch (error:Error) {
            log.error("Error writing shared object to disk.", error);
        }
        if (flushStatus != null) {
            switch (flushStatus) {
                case SharedObjectFlushStatus.PENDING:
                    log.info("Requesting permission to save object...\n");
                    resourcesSharedObject.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                    break;
                case SharedObjectFlushStatus.FLUSHED:
                    log.info("Value flushed to disk.");
                    break;
            }
        }
    }

    private static function onFault(event:FaultEvent):void {
        log.error("Got error loading conferences.", event.fault);
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
        resourcesSharedObject.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
    }
}
}
