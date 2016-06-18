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
import flash.utils.getQualifiedClassName;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.messaging.messages.HTTPRequestMessage;
import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

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
import org.jboss.keycloak.flex.KeycloakRestService;

[Event(type="org.dukecon.events.ConferenceDataChangedEvent", name="conferenceDataChanged")]
[ManagedEvents("conferenceDataChanged")]
public class ConferenceController extends EventDispatcher {

    protected static var log:ILogger = Log.getLogger(getQualifiedClassName(ConferenceController).replace("::", "."));

    private var service:KeycloakRestService;

    private var conn:SQLConnection;
    private var db:File;

    private var streamRatings:SharedObject;

    public var baseUrl:String;

    public function ConferenceController() {
    }

    [Init]
    public function init():void {
        service = new KeycloakRestService();

        // This file will be used for storing the data on the device.
        var db:File = File.applicationStorageDirectory.resolvePath("dukecon-conference.db");
        // This file will be located in
        var initDb:Boolean = !db.exists;

        // Initialize the database.
        conn = new SQLConnection();
        try {
            conn.open(db);

            streamRatings = SharedObject.getLocal("stream-ratings");

            if (initDb) {
                AudienceBase.createTable(conn);
                LanguageBase.createTable(conn);
                EventTypeBase.createTable(conn);
                TrackBase.createTable(conn);
                LocationBase.createTable(conn);
                SpeakerBase.createTable(conn);
                EventBase.createTable(conn);

                // We will use a database table to store the latest etag.
                var createTableStatement:SQLStatement = new SQLStatement();
                createTableStatement.sqlConnection = conn;
                createTableStatement.text = "CREATE TABLE IF NOT EXISTS Etag (tag TEXT, lastUpdated DATE)";
                try {
                    createTableStatement.execute();
                } catch(initError:SQLError) {
                    throw new Error("Error creating table 'Event': " + initError.message);
                }
            }

            if (EventBase.count(conn) == 0) {
                updateEvents();
            }
        } catch (error:SQLError) {
            log.error("Error message:", error.message);
        }
    }

    public function updateEvents():void {
        var etag:String = getEtag();
        var token:AsyncToken = service.send(baseUrl + "/rest/conferences/499959/", HTTPRequestMessage.GET_METHOD,
                null, "application/json", etag);
        token.addEventListener(ResultEvent.RESULT, onResult);
        token.addEventListener(FaultEvent.FAULT, onFault);
    }

    protected function onResult(event:ResultEvent):void {
        // If we get a code 304 this is because we provided an Etag
        // and the server responded with "nothing has changed". No need
        // to do anything in this case.
        if(event.token.status == 304) {
            return;
        }
        
        var result:Object = event.result;

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

        TrackBase.clearTable(conn);
        var persistedStreamIds:Array = [];
        for each(obj in result.metaData.tracks as Array) {
            var stream:Track = new Track(obj);
            if (persistedStreamIds.indexOf(stream.id) == -1) {
                stream.persist(conn);
                persistedStreamIds.push(stream.id);
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

        var insertStatement:SQLStatement = new SQLStatement();
        insertStatement.sqlConnection = conn;
        insertStatement.text = "INSERT OR REPLACE INTO Etag ( tag, lastUpdated) VALUES (:tag, :lastUpdated)";
        insertStatement.parameters[":tag"] = event.token.etag;
        insertStatement.parameters[":lastUpdated"] = new Date();
        try {
            insertStatement.execute();
        } catch(initError:SQLError) {
            throw new Error("Error inserting record into table 'Event': " + initError.message);
        }

        dispatchEvent(new ConferenceDataChangedEvent(ConferenceDataChangedEvent.CONFERENCE_DATA_CHANGED));
    }

    protected function getEtag():String {
        var selectStatement:SQLStatement = new SQLStatement();
        selectStatement.sqlConnection = conn;
        selectStatement.text = "SELECT tag FROM Etag";
        try {
            selectStatement.execute();
            var sqlResult:SQLResult = selectStatement.getResult();
            if(sqlResult.data && sqlResult.data.length > 0) {
                return String(sqlResult.data[0].tag);
            }
        } catch(initError:SQLError) {
            throw new Error("Error selecting records from table 'Event': " + initError.message);
        }
        return null;
    }

    public function get lastUpdatedDate():Date {
        var selectStatement:SQLStatement = new SQLStatement();
        selectStatement.sqlConnection = conn;
        selectStatement.text = "SELECT lastUpdated FROM Etag";
        try {
            selectStatement.execute();
            var sqlResult:SQLResult = selectStatement.getResult();
            if(sqlResult.data && sqlResult.data.length > 0) {
                return (sqlResult.data[0].lastUpdated) as Date;
            }
        } catch(initError:SQLError) {
            throw new Error("Error selecting records from table 'Event': " + initError.message);
        }
        return null;
    }

    protected static function onFault(fault:FaultEvent):void {
        log.error("Something went wrong:" + fault.message);
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

    public function getLanguageName(id:String, locale:String):String {
        var language:Language = getLanguage(id);
        if(language) {
            var parts:Array = locale.split("_");
            return language.names[parts[0]];
        }
        return null;
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

    public function getLocationName(id:String, locale:String):String {
        var location:Location = getLocation(id);
        if(location) {
            var parts:Array = locale.split("_");
            return location.names[parts[0]];
        }
        return null;
    }

    public function get streams():ArrayCollection {
        var streams:ArrayCollection = TrackBase.select(conn);
        var dataSortField:SortField = new SortField();
        dataSortField.name = "order";
        dataSortField.numeric = true;
        var dataSort:Sort = new Sort();
        dataSort.fields = [dataSortField];
        streams.sort = dataSort;
        streams.refresh();
        return streams;
    }

    public function getStream(id:String):Track {
        return TrackBase.selectById(conn, id);
    }

    public function getStreamName(id:String, locale:String):String {
        var stream:Track = getStream(id);
        if(stream) {
            var parts:Array = locale.split("_");
            return stream.names[parts[0]];
        }
        return null;
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

    public function getEventsForDay(day:String):ArrayCollection {
        return EventBase.select(conn, "date(start) = '" + day + "'");
    }

    public function getEventsForStream(stream:Track):ArrayCollection {
        return EventBase.select(conn, "trackId = '" + stream.id + "'");
    }

    public function getEventsForLocation(location:Location):ArrayCollection {
        return EventBase.select(conn, "locationId = '" + location.id + "'");
    }

    public function getEventsForSpeaker(speaker:Speaker):ArrayCollection {
        return EventBase.select(conn, "id IN (" + speaker.eventIds + ")");
    }

    public function setRating(event:Event, rating:Number):void {
        if (!event) return;
        if (!streamRatings.data.savedValue) {
            streamRatings.data.savedValue = {};
        }
        streamRatings.data.savedValue[event.id] = rating;
        flushSharedObject(streamRatings);
    }

    public function getRating(event:Event):Number {
        if (event && streamRatings.data && streamRatings.data.savedValue) {
            return streamRatings.data.savedValue[event.id];
        }
        return -2;
    }

    protected function flushSharedObject(so:SharedObject):void {
        var flushStatus:String = null;
        try {
            flushStatus = so.flush(10000);
        } catch (error:Error) {
            log.error("Error...Could not write SharedObject to disk\n");
        }
        if (flushStatus != null) {
            switch (flushStatus) {
                case SharedObjectFlushStatus.PENDING:
                    log.info("Requesting permission to save object...\n");
                    so.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                    break;
                case SharedObjectFlushStatus.FLUSHED:
                    log.info("Value flushed to disk.\n");
                    break;
            }
        }
    }

    private function onFlushStatus(event:NetStatusEvent):void {
        log.debug("User closed permission dialog...\n");
        switch (event.info.code) {
            case "SharedObject.Flush.Success":
                log.info("User granted permission -- value saved.\n");
                break;
            case "SharedObject.Flush.Failed":
                log.warn("User denied permission -- value not saved.\n");
                break;
        }
        streamRatings.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
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
