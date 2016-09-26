/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {

import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;
import flash.utils.getQualifiedClassName;

import mx.collections.ArrayCollection;
import mx.formatters.DateFormatter;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

import org.dukecon.events.ConferenceDataChangedEvent;
import org.dukecon.model.Conference;
import org.dukecon.model.ConferenceStorage;
import org.dukecon.model.Event;
import org.dukecon.model.Speaker;

[Event(name="conferenceDataChanged", type="org.dukecon.events.ConferenceDataChangedEvent")]
[ManagedEvents("conferenceDataChanged")]
public class ConferenceService extends EventDispatcher {

    protected static var log:ILogger = Log.getLogger(getQualifiedClassName(ConferenceService).replace("::"));

    private var service:RemoteObject;

    [Inject]
    public var serverConnection:ServerConnection;

    private var conferencesSharedObject:SharedObject;

    private var dateFormat:DateFormatter;

    public function ConferenceService() {
        service = new RemoteObject("conferenceService");
        conferencesSharedObject = SharedObject.getLocal("dukecon-conferences");

        dateFormat = new DateFormatter();
        dateFormat.formatString = "YYYY-MM-DD";
    }

    [Init]
    public function init():void {
        // Prepare the remote service.
        service.channelSet = serverConnection.connection;

        service.list.addEventListener(ResultEvent.RESULT, onListResult);
        service.addEventListener(FaultEvent.FAULT, onFault);
    }

    public function update():void {
        log.info("Updating conferences");
        service.list();
    }

    public function get conferences():ArrayCollection {
        var conferences:ArrayCollection = new ArrayCollection();
        for(var conferenceId:String in conferencesSharedObject.data.conferences) {
            conferences.addItem(conferencesSharedObject.data.conferences[conferenceId].conference);
        }
        return conferences;
    }

    public function getConference(conferenceId:String):ConferenceStorage {
        if(conferencesSharedObject.data.conferences.hasOwnProperty(conferenceId)) {
            return ConferenceStorage(conferencesSharedObject.data.conferences[conferenceId]);
        }
        return null;
    }

    public function getConferenceDays(conferenceId:String):ArrayCollection {
        var conference:ConferenceStorage = getConference(conferenceId);
        if(conference) {
            return conference.days;
        }
        return null;
    }

    [Bindable("conferenceDataChanged")]
    public function get lastUpdatedDate():Date {
        if(!conferencesSharedObject.data.lastUpdatedDate) {
            update();
        }
        return conferencesSharedObject.data.lastUpdatedDate;
    }

    private function onListResult(resultEvent:ResultEvent):void {
        log.info("Got response");

        var conferences:Object = {};
        for each(var conference:Conference in resultEvent.result) {
            var conferenceStorage:ConferenceStorage = new ConferenceStorage();
            conferenceStorage.id = conference.id;
            conferenceStorage.conference = conference;
            conferenceStorage.days = new ArrayCollection();
            conferenceStorage.audienceIndex = {};
            conferenceStorage.eventTypeIndex = {};
            conferenceStorage.languageIndex = {};
            conferenceStorage.locationIndex = {};
            conferenceStorage.speakerIndex = {};
            conferenceStorage.streamIndex = {};
            conferenceStorage.dayIndex = {};

            // Build up some helpful indexes that prevent us from having to process
            // all events for each list operation.
            for each(var event:Event in conference.events) {
                var dateString:String = dateFormat.format(event.start);
                if(conferenceStorage.days.getItemIndex(dateString) == -1) {
                    conferenceStorage.days.addItem(dateString)
                }

                if(event.audience) {
                    if(!conferenceStorage.audienceIndex.hasOwnProperty(event.audience.id)) {
                        conferenceStorage.audienceIndex[event.audience.id] = new ArrayCollection();
                    }
                    ArrayCollection(conferenceStorage.audienceIndex[event.audience.id]).addItem(event);
                }

                if(event.type) {
                    if(!conferenceStorage.eventTypeIndex.hasOwnProperty(event.type.id)) {
                        conferenceStorage.eventTypeIndex[event.type.id] = new ArrayCollection();
                    }
                    ArrayCollection(conferenceStorage.eventTypeIndex[event.type.id]).addItem(event);
                }

                if(event.language) {
                    if(!conferenceStorage.languageIndex.hasOwnProperty(event.language.id)) {
                        conferenceStorage.languageIndex[event.language.id] = new ArrayCollection();
                    }
                    ArrayCollection(conferenceStorage.languageIndex[event.language.id]).addItem(event);
                }

                if(event.location) {
                    if(!conferenceStorage.locationIndex.hasOwnProperty(event.location.id)) {
                        conferenceStorage.locationIndex[event.location.id] = new ArrayCollection();
                    }
                    ArrayCollection(conferenceStorage.locationIndex[event.location.id]).addItem(event);
                }

                if(event.speakers) {
                    for each(var speaker:Speaker in event.speakers) {
                        if(!conferenceStorage.speakerIndex.hasOwnProperty(speaker.id)) {
                            conferenceStorage.speakerIndex[speaker.id] = new ArrayCollection();
                        }
                        ArrayCollection(conferenceStorage.speakerIndex[speaker.id]).addItem(event);
                    }
                }

                if(event.track) {
                    if(!conferenceStorage.streamIndex.hasOwnProperty(event.track.id)) {
                        conferenceStorage.streamIndex[event.track.id] = new ArrayCollection();
                    }
                    ArrayCollection(conferenceStorage.streamIndex[event.track.id]).addItem(event);
                }

                if(!conferenceStorage.dayIndex.hasOwnProperty(dateString)) {
                    conferenceStorage.dayIndex[dateString] = new ArrayCollection();
                }
                ArrayCollection(conferenceStorage.dayIndex[dateString]).addItem(event);
            }

            conferences[conferenceStorage.id] = conferenceStorage;
        }

        conferencesSharedObject.data.conferences = conferences;
        conferencesSharedObject.data.lastUpdatedDate = new Date();

        var flushStatus:String = null;
        try {
            flushStatus = conferencesSharedObject.flush(10000);
        } catch (error:Error) {
            log.error("Error writing shared object to disk.", error);
        }
        if (flushStatus != null) {
            switch (flushStatus) {
                case SharedObjectFlushStatus.PENDING:
                    log.info("Requesting permission to save object...\n");
                    conferencesSharedObject.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                    break;
                case SharedObjectFlushStatus.FLUSHED:
                    log.info("Value flushed to disk.");
                    dispatchEvent(ConferenceDataChangedEvent.createConferenceDataChangedEvent());
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
        conferencesSharedObject.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
        dispatchEvent(ConferenceDataChangedEvent.createConferenceDataChangedEvent());
    }

}
}
