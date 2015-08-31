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
import org.dukecon.model.ConferenceBase;
import org.dukecon.model.MetaDataBase;
import org.dukecon.model.Speaker;
import org.dukecon.model.SpeakerBase;
import org.dukecon.model.Talk;
import org.dukecon.model.TalkBase;
import org.dukecon.model.UserPreferenceBase;

[Event(type="org.dukecon.events.ConferenceDataChangedEvent", name="conferenceDataChanged")]
public class ConferenceController extends EventDispatcher {

    private static var _instance:ConferenceController;

    public static function get instance():ConferenceController {
        if(!_instance) {
            _instance = new ConferenceController(new SingletonEnforcer());
        }
        return _instance;
    }

    private var service:HTTPService;

    private var conn:SQLConnection;
    private var db:File;

    private var selectedTalkIds:SharedObject;
    private var trackRatings:SharedObject;

    public function ConferenceController(enforcer:SingletonEnforcer) {

        service = new HTTPService();
        service.method = "GET";
        service.contentType = "application/json";
        service.headers = { Accept:"application/json" };
        service.url = "http://dev.dukecon.org/latest/rest/talks/";

        // This file will be used for storing the data on the device.
        var db:File = File.applicationStorageDirectory.resolvePath("dukecon.db");
        // This file will be located in
        var initDb:Boolean = !db.exists;

        // Initialize the database.
        conn = new SQLConnection();
        try {
            conn.open(db);

            selectedTalkIds = SharedObject.getLocal("selected-talk-ids");
            trackRatings = SharedObject.getLocal("track-ratings");

            if(initDb) {
                TalkBase.createTable(conn);
                SpeakerBase.createTable(conn);
                MetaDataBase.createTable(conn);
                ConferenceBase.createTable(conn);
                UserPreferenceBase.clearTable(conn);
            }

            if(TalkBase.count(conn) == 0) {
                updateTalks();
            }
        } catch(error:SQLError) {
            trace("Error message:", error.message);
        }
    }

    public function updateTalks():void {
        var token:AsyncToken = service.send();
        token.addResponder(new Responder(onResult, onFault));
    }

    protected function onResult(event:ResultEvent):void {
        var result:Object = JSON.parse(String(event.result));
        TalkBase.clearTable(conn);
        SpeakerBase.clearTable(conn);
        var persistedSpeakers:Array = [];
        for each(var obj:Object in result as Array) {
            var talk:Talk = new Talk(obj);
            for each(var speakerObj:Object in talk.speakers) {
                if(speakerObj) {
                    var speaker:Speaker = new Speaker(speakerObj);
                    if(persistedSpeakers.indexOf(speaker.name + "-" + speaker.company) == -1) {
                        speaker.persist(conn);
                        persistedSpeakers.push(speaker.name + "-" + speaker.company);
                    }
                }
            }
            talk.persist(conn);
        }
        dispatchEvent(new ConferenceDataChangedEvent(ConferenceDataChangedEvent.CONFERENCE_DATA_CHANGED));
    }

    protected function onFault(foult:FaultEvent):void {
        trace("Something went wrong:" + foult.message);
    }

    public function get talks():ArrayCollection {
        var talks:ArrayCollection = TalkBase.select(conn);

        var sortField:SortField = new SortField();
        sortField.name = "start";
        sortField.compareFunction = function(a:Object, b:Object):int {
            var aTime:Number = (a.start as Date).getTime();
            var bTime:Number = (b.start as Date).getTime();
            if(aTime < bTime) {
                return -1;
            }
            if(aTime > bTime) {
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
            if(obj.day) {
                result.addItem(obj.day);
            }
        }
        return result;
    }

    public function get locations():ArrayCollection {
        var locations:ArrayCollection = executeQuery("SELECT DISTINCT location FROM Talk");
        var result:ArrayCollection = new ArrayCollection();
        for each(var obj:Object in locations) {
            if(obj.location) {
                result.addItem(obj.location);
            }
        }
        return result;
    }

    public function get tracks():ArrayCollection {
        var tracks:ArrayCollection = executeQuery("SELECT DISTINCT track FROM Talk");
        var result:ArrayCollection = new ArrayCollection();
        for each(var obj:Object in tracks) {
            if(obj.track) {
                result.addItem(obj.track);
            }
        }
        var dataSortField:SortField = new SortField();
        dataSortField.numeric = false;
        var dataSort:Sort = new Sort();
        dataSort.fields=[dataSortField];
        result.sort = dataSort;
        result.refresh();
        return result;
    }

    public function getTimeSlotsForDay(day:String):ArrayCollection {
        var slots:ArrayCollection = executeQuery("SELECT DISTINCT (strftime('%H:%M', start) || ' - ' || " +
                "strftime('%H:%M', end)) AS slot FROM Talk WHERE date(start) = '" + day + "'");
        var result:ArrayCollection = new ArrayCollection();
        for each(var obj:Object in slots) {
            if(obj.slot) {
                result.addItem(obj.slot);
            }
        }
        var dataSortField:SortField = new SortField();
        dataSortField.numeric = false;
        var dataSort:Sort = new Sort();
        dataSort.fields=[dataSortField];
        result.sort = dataSort;
        result.refresh();
        return result;
    }

    public function getTalksForDay(day:String):ArrayCollection {
        return TalkBase.select(conn, "date(start) = '" + day + "'");
    }

    public function getTalksForTrack(track:String):ArrayCollection {
        return TalkBase.select(conn, "track = '" + track + "'");
    }

    public function getTalksForLocation(location:String):ArrayCollection {
        return TalkBase.select(conn, "location = '" + location + "'");
    }

    public function getTalksForSpeaker(speaker:Speaker):ArrayCollection {
        var result:ArrayCollection = new ArrayCollection();
        for each(var talk:Talk in talks) {
            for each(var speakerObj:Object in talk.speakers) {
                if(speakerObj && speakerObj.name == speaker.name) {
                    result.addItem(talk);
                    break;
                }
            }
        }
        return result;
    }

    public function isTalkSelected(talk:Talk):Boolean {
        if(!talk) return false;
        return (selectedTalkIds.data && selectedTalkIds.data.savedValue &&
            ArrayCollection(selectedTalkIds.data.savedValue).contains(talk.id));
    }

    public function selectTalk(talk:Talk):void {
        if(!talk) return;
        if(!selectedTalkIds.data.savedValue) {
            selectedTalkIds.data.savedValue = new ArrayCollection();
        }
        if(!ArrayCollection(selectedTalkIds.data.savedValue).contains(talk.id)) {
            ArrayCollection(selectedTalkIds.data.savedValue).addItem(talk.id);
            flushSharedObject(selectedTalkIds);
        }
    }

    public function unselectTalk(talk:Talk):void {
        if(!talk) return;
        if(isTalkSelected(talk)) {
            ArrayCollection(selectedTalkIds.data.savedValue).removeItem(talk.id);
            flushSharedObject(selectedTalkIds);
        }
    }

    public function setRating(talk:Talk, rating:Number):void {
        if(!talk) return;
        if(!trackRatings.data.savedValue) {
            trackRatings.data.savedValue = {};
        }
        trackRatings.data.savedValue[talk.id] = rating;
        flushSharedObject(trackRatings);
    }

    public function getRating(talk:Talk):Number {
        if(talk && trackRatings.data && trackRatings.data.savedValue) {
            return trackRatings.data.savedValue[talk.id];
        }
        return -2;
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
        selectedTalkIds.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
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
        } catch(initError:SQLError) {
            throw new Error("Error selecting records from table '${jClass.as3Type.name}': " + initError.message);
        }
        return result;
    }
    
}
}
class SingletonEnforcer{}
