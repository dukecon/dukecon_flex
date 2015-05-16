package org.dukecon.controller {

import flash.data.SQLConnection;
import flash.errors.SQLError;
import flash.events.EventDispatcher;
import flash.filesystem.File;

import mx.collections.ArrayList;

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
        service.url = "http://localhost:8080/talks/";

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
            trace("Details:", error.details);
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

    protected function onFault(event:FaultEvent):void {
        trace("crap!");
    }

    public function get talks():ArrayList {
        return TalkBase.select(conn);
    }

}
}
class SingletonEnforcer{}
