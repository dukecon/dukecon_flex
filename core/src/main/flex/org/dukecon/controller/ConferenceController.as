package org.dukecon.controller {

import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.filesystem.File;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.rpc.AsyncToken;
import mx.rpc.Responder;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;

import org.dukecon.events.ConferenceDataChangedEvent;
import org.dukecon.model.Audience;
import org.dukecon.model.AudienceBase;
import org.dukecon.model.Event;
import org.dukecon.model.EventBase;
import org.dukecon.model.EventType;
import org.dukecon.model.EventTypeBase;
import org.dukecon.model.Language;
import org.dukecon.model.LanguageBase;
import org.dukecon.model.Location;
import org.dukecon.model.LocationBase;
import org.dukecon.model.Speaker;
import org.dukecon.model.SpeakerBase;
import org.dukecon.model.Track;
import org.dukecon.model.TrackBase;

[Event(type="org.dukecon.events.ConferenceDataChangedEvent", name="conferenceDataChanged")]
[ManagedEvents("conferenceDataChanged")]
public class ConferenceController extends EventDispatcher {

    private var service:HTTPService;

    private var conn:SQLConnection;
    private var db:File;

    private var trackRatings:SharedObject;

    public var baseUrl:String;

    public function ConferenceController() {
    }

    [Init]
    public function init():void {
        service = new HTTPService();
        service.method = "GET";
        service.contentType = "application/json";
        service.headers = {Accept: "application/json"};
        service.url = baseUrl + "/rest/conferences/499959/";

        // This file will be used for storing the data on the device.
        var db:File = File.applicationStorageDirectory.resolvePath("dukecon-conference.db");
        // This file will be located in
        var initDb:Boolean = !db.exists;

        // Initialize the database.
        conn = new SQLConnection();
        try {
            conn.open(db);

            trackRatings = SharedObject.getLocal("track-ratings");

            if (initDb) {
                AudienceBase.createTable(conn);
                LanguageBase.createTable(conn);
                EventTypeBase.createTable(conn);
                TrackBase.createTable(conn);
                LocationBase.createTable(conn);
                SpeakerBase.createTable(conn);
                EventBase.createTable(conn);
            }

            if (EventBase.count(conn) == 0) {
                updateEvents();
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
        }
    }

    public function updateEvents():void {
        var token:AsyncToken = service.send();
        token.addResponder(new Responder(onResult, onFault));
    }

    protected function onResult(event:ResultEvent):void {
        var resultData:String = event.result.toString();
        var result:Object = JSON.parse(resultData);

        EventBase.clearTable(conn);

        var obj:Object;

        AudienceBase.clearTable(conn);
        var persistedAudienceIds:Array = [];
        for each(obj in result.metaData.audiences as Array) {
            var audience:Audience = new Audience(obj);
            if (persistedAudienceIds.indexOf(audience.id) == -1) {
                audience.persist(conn);
                persistedAudienceIds.push(audience.id);
            }
        }

        LanguageBase.clearTable(conn);
        var persistedLanguageIds:Array = [];
        for each(obj in result.metaData.languages as Array) {
            var language:Language = new Language(obj);
            if (persistedLanguageIds.indexOf(language.id) == -1) {
                language.persist(conn);
                persistedLanguageIds.push(language.id);
            }
        }

        EventTypeBase.clearTable(conn);
        var persistedEventTypeIds:Array = [];
        for each(obj in result.metaData.eventTypes as Array) {
            var eventType:EventType = new EventType(obj);
            if (persistedEventTypeIds.indexOf(eventType.id) == -1) {
                eventType.persist(conn);
                persistedEventTypeIds.push(eventType.id);
            }
        }

        TrackBase.createTable(conn);
        var persistedTrackIds:Array = [];
        for each(obj in result.metaData.tracks as Array) {
            var track:Track = new Track(obj);
            if (persistedTrackIds.indexOf(track.id) == -1) {
                track.persist(conn);
                persistedTrackIds.push(track.id);
            }
        }

        LocationBase.clearTable(conn);
        var persistedRoomIds:Array = [];
        for each(obj in result.metaData.locations as Array) {
            var location:Location = new Location(obj);
            if (persistedRoomIds.indexOf(location.id) == -1) {
                location.persist(conn);
                persistedRoomIds.push(location.id);
            }
        }

        SpeakerBase.clearTable(conn);
        var persistedSpeakerIds:Array = [];
        for each(obj in result.speakers as Array) {
            var speaker:Speaker = new Speaker(obj);
            if (persistedSpeakerIds.indexOf(speaker.id) == -1) {
                speaker.persist(conn);
                persistedSpeakerIds.push(speaker.id);
            }
        }

        EventBase.clearTable(conn);
        var persistedEventIds:Array = [];
        for each(obj in result.events as Array) {
            var evnt:Event = new Event(obj);
            if (persistedEventIds.indexOf(evnt.id) == -1) {
                evnt.persist(conn);
                persistedEventIds.push(evnt.id);
            }
        }

        dispatchEvent(new ConferenceDataChangedEvent(ConferenceDataChangedEvent.CONFERENCE_DATA_CHANGED));
    }

    protected static function onFault(fault:FaultEvent):void {
        trace("Something went wrong:" + fault.message);
    }

    public function get events():ArrayCollection {
        var talks:ArrayCollection = EventBase.select(conn);

        var sortField:SortField = new SortField();
        sortField.name = "start";
        sortField.compareFunction = function (a:Object, b:Object):int {
            var aTime:Number = (a.start as Date).getTime();
            var bTime:Number = (b.start as Date).getTime();
            if (aTime < bTime) {
                return -1;
            }
            if (aTime > bTime) {
                return 1;
            }
            return 0;
        };
        var sort:Sort = new Sort();
        sort.fields = [sortField];
        talks.sort = sort;

        return talks;
    }

    public function get days():ArrayCollection {
        var days:ArrayCollection = executeQuery("SELECT DISTINCT date(start) AS day FROM Event");
        var result:ArrayCollection = new ArrayCollection();
        for each(var obj:Object in days) {
            if (obj.day) {
                result.addItem(obj.day);
            }
        }
        return result;
    }

    public function get languages():ArrayCollection {
        var languages:ArrayCollection = LanguageBase.select(conn);
        var dataSortField:SortField = new SortField();
        dataSortField.name = "order";
        dataSortField.numeric = true;
        var dataSort:Sort = new Sort();
        dataSort.fields = [dataSortField];
        languages.sort = dataSort;
        languages.refresh();
        return languages;
    }

    public function getLanguage(id:String):Language {
        return LanguageBase.selectById(conn, id);
    }

    public function get locations():ArrayCollection {
        var locations:ArrayCollection = LocationBase.select(conn);
        var dataSortField:SortField = new SortField();
        dataSortField.name = "order";
        dataSortField.numeric = true;
        var dataSort:Sort = new Sort();
        dataSort.fields = [dataSortField];
        locations.sort = dataSort;
        locations.refresh();
        return locations;
    }

    public function getLocation(id:String):Location {
        return LocationBase.selectById(conn, id);
    }

    public function get tracks():ArrayCollection {
        var tracks:ArrayCollection = TrackBase.select(conn);
        var dataSortField:SortField = new SortField();
        dataSortField.name = "order";
        dataSortField.numeric = true;
        var dataSort:Sort = new Sort();
        dataSort.fields = [dataSortField];
        tracks.sort = dataSort;
        tracks.refresh();
        return tracks;
    }

    public function getTrack(id:String):Track {
        return TrackBase.selectById(conn, id);
    }

    public function get speakers():ArrayCollection {
        var speakers:ArrayCollection = SpeakerBase.select(conn);

        var sortField:SortField = new SortField();
        sortField.name = "name";
        sortField.numeric = false;
        var sort:Sort = new Sort();
        sort.fields = [sortField];
        speakers.sort = sort;
        speakers.refresh();

        return speakers;
    }

    public function getSpeaker(id:String):Speaker {
        return SpeakerBase.selectById(conn, id);
    }

    public function getTimeSlotsForDay(day:String):ArrayCollection {
        var slots:ArrayCollection = executeQuery("SELECT DISTINCT (strftime('%H:%M', start) || ' - ' || " +
                "strftime('%H:%M', end)) AS slot FROM Event WHERE date(start) = '" + day + "'");
        var result:ArrayCollection = new ArrayCollection();
        for each(var obj:Object in slots) {
            if (obj.slot) {
                result.addItem(obj.slot);
            }
        }
        var dataSortField:SortField = new SortField();
        dataSortField.numeric = false;
        var dataSort:Sort = new Sort();
        dataSort.fields = [dataSortField];
        result.sort = dataSort;
        result.refresh();
        return result;
    }

    public function getEventsForDay(day:String):ArrayCollection {
        return EventBase.select(conn, "date(start) = '" + day + "'");
    }

    public function getEventsForTrack(track:Track):ArrayCollection {
        return EventBase.select(conn, "trackId = '" + track.id + "'");
    }

    public function getEventsForLocation(location:Location):ArrayCollection {
        return EventBase.select(conn, "locationId = '" + location.id + "'");
    }

    public function getEventsForSpeaker(speaker:Speaker):ArrayCollection {
        return EventBase.select(conn, "id IN (" + speaker.eventIds + ")");
    }

    public function setRating(event:Event, rating:Number):void {
        if (!event) return;
        if (!trackRatings.data.savedValue) {
            trackRatings.data.savedValue = {};
        }
        trackRatings.data.savedValue[event.id] = rating;
        flushSharedObject(trackRatings);
    }

    public function getRating(event:Event):Number {
        if (event && trackRatings.data && trackRatings.data.savedValue) {
            return trackRatings.data.savedValue[event.id];
        }
        return -2;
    }

    protected function flushSharedObject(so:SharedObject):void {
        var flushStatus:String = null;
        try {
            flushStatus = so.flush(10000);
        } catch (error:Error) {
            trace("Error...Could not write SharedObject to disk\n");
        }
        if (flushStatus != null) {
            switch (flushStatus) {
                case SharedObjectFlushStatus.PENDING:
                    trace("Requesting permission to save object...\n");
                    so.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                    break;
                case SharedObjectFlushStatus.FLUSHED:
                    trace("Value flushed to disk.\n");
                    break;
            }
        }
    }

    private function onFlushStatus(event:NetStatusEvent):void {
        trace("User closed permission dialog...\n");
        switch (event.info.code) {
            case "SharedObject.Flush.Success":
                trace("User granted permission -- value saved.\n");
                break;
            case "SharedObject.Flush.Failed":
                trace("User denied permission -- value not saved.\n");
                break;
        }
        trackRatings.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
    }

    protected function executeQuery(query:String):ArrayCollection {
        var result:ArrayCollection = new ArrayCollection();
        var selectStatement:SQLStatement = new SQLStatement();
        selectStatement.sqlConnection = conn;
        selectStatement.text = query;
        try {
            selectStatement.execute();
            var sqlResult:SQLResult = selectStatement.getResult();
            for each(var obj:Object in sqlResult.data) {
                result.addItem(obj);
            }
        } catch (error:SQLError) {
            throw new Error("Error selecting records from table 'Events': " + error.message);
        }
        return result;
    }

}
}
