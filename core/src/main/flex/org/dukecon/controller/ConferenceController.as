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
import org.dukecon.model.Language;
import org.dukecon.model.LanguageBase;
import org.dukecon.model.Room;
import org.dukecon.model.RoomBase;
import org.dukecon.model.Speaker;
import org.dukecon.model.SpeakerBase;
import org.dukecon.model.Talk;
import org.dukecon.model.TalkBase;
import org.dukecon.model.TalkType;
import org.dukecon.model.TalkTypeBase;
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
        service.url = baseUrl + "/rest/conference/";

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
                TalkTypeBase.createTable(conn);
                TrackBase.createTable(conn);
                RoomBase.createTable(conn);
                SpeakerBase.createTable(conn);
                TalkBase.createTable(conn);
            }

            if (TalkBase.count(conn) == 0) {
                updateTalks();
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
        }
    }

    public function updateTalks():void {
        var token:AsyncToken = service.send();
        token.addResponder(new Responder(onResult, onFault));
    }

    protected function onResult(event:ResultEvent):void {
        var resultData:String = event.result.toString();
        var result:Object = JSON.parse(resultData);

        TalkBase.clearTable(conn);

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

        TalkTypeBase.clearTable(conn);
        var persistedTalkTypeIds:Array = [];
        for each(obj in result.metaData.talkTypes as Array) {
            var talkType:TalkType = new TalkType(obj);
            if (persistedTalkTypeIds.indexOf(talkType.id) == -1) {
                talkType.persist(conn);
                persistedTalkTypeIds.push(talkType.id);
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

        RoomBase.clearTable(conn);
        var persistedRoomIds:Array = [];
        for each(obj in result.metaData.rooms as Array) {
            var room:Room = new Room(obj);
            if (persistedRoomIds.indexOf(room.id) == -1) {
                room.persist(conn);
                persistedRoomIds.push(room.id);
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

        TalkBase.clearTable(conn);
        var persistedTalkIds:Array = [];
        for each(obj in result.talks as Array) {
            var talk:Talk = new Talk(obj);
            if (persistedTalkIds.indexOf(talk.id) == -1) {
                talk.persist(conn);
                persistedTalkIds.push(talk.id);
            }
        }

        dispatchEvent(new ConferenceDataChangedEvent(ConferenceDataChangedEvent.CONFERENCE_DATA_CHANGED));
    }

    protected static function onFault(fault:FaultEvent):void {
        trace("Something went wrong:" + fault.message);
    }

    public function get talks():ArrayCollection {
        var talks:ArrayCollection = TalkBase.select(conn);

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
        var days:ArrayCollection = executeQuery("SELECT DISTINCT date(start) AS day FROM Talk");
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

    public function get rooms():ArrayCollection {
        var rooms:ArrayCollection = RoomBase.select(conn);
        var dataSortField:SortField = new SortField();
        dataSortField.name = "order";
        dataSortField.numeric = true;
        var dataSort:Sort = new Sort();
        dataSort.fields = [dataSortField];
        rooms.sort = dataSort;
        rooms.refresh();
        return rooms;
    }

    public function getRoom(id:String):Room {
        return RoomBase.selectById(conn, id);
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
                "strftime('%H:%M', end)) AS slot FROM Talk WHERE date(start) = '" + day + "'");
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

    public function getTalksForDay(day:String):ArrayCollection {
        return TalkBase.select(conn, "date(start) = '" + day + "'");
    }

    public function getTalksForTrack(track:Track):ArrayCollection {
        return TalkBase.select(conn, "trackId = '" + track.id + "'");
    }

    public function getTalksForRoom(room:Room):ArrayCollection {
        return TalkBase.select(conn, "roomId = '" + room.id + "'");
    }

    public function getTalksForSpeaker(speaker:Speaker):ArrayCollection {
        return TalkBase.select(conn, "id IN (" + speaker.talkIds + ")");
    }

    public function setRating(talk:Talk, rating:Number):void {
        if (!talk) return;
        if (!trackRatings.data.savedValue) {
            trackRatings.data.savedValue = {};
        }
        trackRatings.data.savedValue[talk.id] = rating;
        flushSharedObject(trackRatings);
    }

    public function getRating(talk:Talk):Number {
        if (talk && trackRatings.data && trackRatings.data.savedValue) {
            return trackRatings.data.savedValue[talk.id];
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
            throw new Error("Error selecting records from table 'Talks': " + error.message);
        }
        return result;
    }

}
}
