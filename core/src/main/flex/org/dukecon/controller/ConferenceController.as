package org.dukecon.controller {

import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.events.EventDispatcher;
import flash.filesystem.File;

import mx.collections.ArrayCollection;
import mx.collections.ISort;
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
import org.dukecon.model.SpeakerBase;
import org.dukecon.model.Talk;
import org.dukecon.model.TalkBase;

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

    public function ConferenceController(enforcer:SingletonEnforcer) {

        service = new HTTPService();
        service.method = "GET";
        service.contentType = "application/json";
        service.headers = { Accept:"application/json" };
        service.url = "http://dev.dukecon.org:9090/talks/";

        // This file will be used for storing the data on the device.
        var db:File = File.applicationStorageDirectory.resolvePath("dukecon.db");
        // This file will be located in
        var initDb:Boolean = !db.exists;

        // Initialize the database.
        conn = new SQLConnection();
        try {
            conn.open(db);

            if(initDb) {
                TalkBase.createTable(conn);
                SpeakerBase.createTable(conn);
                MetaDataBase.createTable(conn);
                ConferenceBase.createTable(conn)
            }

            if(TalkBase.count(conn) == 0) {
                updateTalks();
            }
        } catch(error:SQLError) {
            trace("Error message:", error.message);
        }
    }

    protected function updateTalks():void {
        var token:AsyncToken = service.send();
        token.addResponder(new Responder(onResult, onFault));
    }

    protected function onResult(event:ResultEvent):void {
        var result:Object = JSON.parse(String(event.result));
        TalkBase.clearTable(conn);
        for each(var obj:Object in result as Array) {
            var talk:Talk = new Talk(obj);
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

    public function get speakers():ArrayCollection {
        var speakers:ArrayCollection = executeQuery("SELECT DISTINCT speakers FROM Talk");
        var result:ArrayCollection = new ArrayCollection();
        for each(var obj:Object in speakers) {
            if(obj.speakers) {
                for each(var speaker:Object in (obj.speakers as Array)) {
                    if(speaker && (!result.contains(speaker.name))) {
                        result.addItem(speaker.name);
                    }
                }
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
