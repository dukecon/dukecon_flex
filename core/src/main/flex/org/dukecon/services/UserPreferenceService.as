/**
 * Created by christoferdutz on 27.08.16.
 */
package org.dukecon.services {
import flash.events.NetStatusEvent;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;
import flash.utils.getQualifiedClassName;

import mx.logging.ILogger;
import mx.logging.Log;

import org.dukecon.model.Event;

public class UserPreferenceService {

    protected static var log:ILogger = Log.getLogger(getQualifiedClassName(UserPreferenceService).replace("::"));

    private var preferencesSharedObject:SharedObject;

    public function UserPreferenceService() {
        preferencesSharedObject = SharedObject.getLocal("dukecon-preferences");
        if(!preferencesSharedObject.data.preferences) {
            preferencesSharedObject.data.preferences = {};
        }
    }

    public function isEventSelected(event:Event):Boolean {
        return Object(preferencesSharedObject.data.preferences).hasOwnProperty(event.conference.id + "-" + event.id)
    }

    public function selectEvent(event:Event):void {
        Object(preferencesSharedObject.data.preferences)[event.conference.id + "-" + event.id] = "true";
        saveSettings();
    }

    public function unselectEvent(event:Event):void {
        delete Object(preferencesSharedObject.data.preferences)[event.conference.id + "-" + event.id];
        saveSettings();
    }

    private function saveSettings():void {
        var flushStatus:String = null;
        try {
            flushStatus = preferencesSharedObject.flush(10000);
        } catch (error:Error) {
            log.error("Error writing shared object to disk.", error);
        }
        if (flushStatus != null) {
            switch (flushStatus) {
                case SharedObjectFlushStatus.PENDING:
                    log.info("Requesting permission to save object...\n");
                    preferencesSharedObject.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
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
        preferencesSharedObject.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
    }

}
}
