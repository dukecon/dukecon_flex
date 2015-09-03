/**
 * Created by christoferdutz on 31.08.15.
 */
package org.dukecon.controller {
import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.events.EventDispatcher;
import flash.filesystem.File;

import mx.collections.ArrayCollection;
import mx.messaging.messages.HTTPRequestMessage;
import mx.rpc.AsyncToken;
import mx.rpc.Responder;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;

import org.dukecon.events.ConferenceDataChangedEvent;
import org.dukecon.events.UserPreferenceDataChangedEvent;
import org.dukecon.model.Talk;
import org.dukecon.model.UserPreference;
import org.dukecon.model.UserPreferenceBase;

[Event(type="org.dukecon.events.UserPreferenceDataChangedEvent", name="userPreferenceDataChanged")]
public class UserPreferenceController extends EventDispatcher {
    private static var _instance:UserPreferenceController;

    public static function get instance():UserPreferenceController {
        if(!_instance) {
            _instance = new UserPreferenceController(new SingletonEnforcer());
        }
        return _instance;
    }

    private var service:HTTPService;

    private var conn:SQLConnection;
    private var db:File;

    public function UserPreferenceController(enforcer:SingletonEnforcer) {

        service = new HTTPService();
        service.contentType = "application/json";
        service.url = "http://dev.dukecon.org/latest/rest/preferences";

        // This file will be used for storing the data on the device.
        var db:File = File.applicationStorageDirectory.resolvePath("dukecon-user-preferences.db");
        // This file will be located in
        var initDb:Boolean = !db.exists;

        // Initialize the database.
        conn = new SQLConnection();
        try {
            conn.open(db);

            if(initDb) {
                UserPreferenceBase.createTable(conn);
            }
        } catch(error:SQLError) {
            trace("Error message:", error.message);
        }
    }

    public function readUserPreferences():void {
        service.method = HTTPRequestMessage.GET_METHOD;
        service.headers = { Accept:"application/json",
            Authorization: "Bearer " + OAuthControllerSimple.instance.oauthData.access_token };
        var token:AsyncToken = service.send();
        token.addResponder(new Responder(onReadResult, onFault));
    }

    public function writeUserPreferences():void {
        service.method = HTTPRequestMessage.POST_METHOD;
        service.headers = { Accept:"application/json",
            Authorization: "Bearer " + OAuthControllerSimple.instance.oauthData.access_token };
        var jsonString:String = JSON.stringify(userPreferences);
        var token:AsyncToken = service.send(jsonString);
        token.addResponder(new Responder(onWriteResult, onFault));
    }

    protected function onReadResult(event:ResultEvent):void {
        var result:Object = JSON.parse(String(event.result));
        UserPreferenceBase.clearTable(conn);
        for each(var obj:Object in result as Array) {
            var userPreference:UserPreference = new UserPreference(obj);
            userPreference.persist(conn);
        }
        dispatchEvent(new ConferenceDataChangedEvent(UserPreferenceDataChangedEvent.USER_PREFERENCE_DATA_CHANGED));
    }

    protected function onWriteResult(event:ResultEvent):void {
        trace("Saved");
    }

    protected function onFault(fault:FaultEvent):void {
        trace("Something went wrong:" + fault.message);
    }

    public function get userPreferences():ArrayCollection {
        var talks:ArrayCollection = UserPreferenceBase.select(conn);
        return talks;
    }

    public function isTalkSelected(talk:Talk):Boolean {
        if(!talk) return false;
        var userPreferences:ArrayCollection = executeQuery("SELECT DISTINCT talkId FROM UserPreference WHERE talkId = '" + talk.id + "'");
        return userPreferences && (userPreferences.length > 0);
    }

    public function selectTalk(talk:Talk):void {
        if(!talk) return;
        var userPreference:UserPreference = new UserPreference();
        userPreference.talkId = talk.id;
        userPreference.version = 0;
        userPreference.persist(conn);

        // Write the preferences back to the server.
        writeUserPreferences();
    }

    public function unselectTalk(talk:Talk):void {
        if(!talk) return;
        if(isTalkSelected(talk)) {
            executeQuery("DELETE FROM UserPreference WHERE talkId = '" + talk.id + "'");
        }

        // Write the preferences back to the server.
        writeUserPreferences();
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
