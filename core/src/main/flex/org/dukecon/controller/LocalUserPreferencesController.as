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
import flash.utils.getQualifiedClassName;

import mx.collections.ArrayCollection;
import mx.logging.ILogger;
import mx.logging.Log;

import org.dukecon.model.Event;
import org.dukecon.model.user.UserPreference;
import org.dukecon.model.user.UserPreferenceBase;

public class LocalUserPreferencesController extends EventDispatcher implements UserPreferencesController {

    protected static var log:ILogger = Log.getLogger(getQualifiedClassName(LocalUserPreferencesController).replace("::", "."));

    [Bindable]
    protected var featureServerFavorites:Boolean = FEATURE::serverFavorites;

    [Inject]
    public var remoteUserPreferencesController:RemoteUserPreferencesController;

    private var conn:SQLConnection;
    private var db:File;
    
    public function LocalUserPreferencesController() {
        super ();
    }

    [Init]
    public function init():void {
        // This file will be used for storing the data on the device.
        var db:File = File.applicationStorageDirectory.resolvePath("dukecon-user-preferences.db");
        // This file will be located in
        var initDb:Boolean = !db.exists;

        // Initialize the database.
        conn = new SQLConnection();
        try {
            conn.open(db);
            if (initDb) {
                UserPreferenceBase.createTable(conn);
            }
        } catch (error:SQLError) {
            log.error("Error message:", error.message);
        }
    }
    
    public function list():ArrayCollection {
        var events:ArrayCollection = UserPreferenceBase.select(conn);
        return events;
    }

    public function replaceAll(userPreferences:ArrayCollection):void {
        UserPreferenceBase.clearTable(conn);
        for each(var userPreference:UserPreference in userPreferences) {
            userPreference.persist(conn);
        }
    }

    public function add(userPreference:UserPreference):void {
        if (!userPreference || (userPreference.eventId == null)) return;
        userPreference.version = 0;
        userPreference.persist(conn);

        // If the user has a server-backed profile, also add it on the server.
        if(featureServerFavorites && remoteUserPreferencesController &&
                remoteUserPreferencesController.connectedToRemote) {
            remoteUserPreferencesController.add(userPreference);
        }
    }

    public function del(userPreference:UserPreference):void {
        if (!userPreference) return;
        var userPreferences:ArrayCollection = UserPreferenceBase.select(conn, "eventId = " + userPreference.eventId);
        if (userPreferences != null) {
            executeQuery("DELETE FROM UserPreference WHERE eventId = '" + userPreference.eventId + "'");
        }

        // If the user has a server-backed profile, also remove it on the server.
        if(featureServerFavorites && remoteUserPreferencesController &&
                remoteUserPreferencesController.connectedToRemote) {
            remoteUserPreferencesController.del(userPreference);
        }
    }

    public function isEventSelected(event:org.dukecon.model.Event):Boolean {
        if (!event) return false;
        var userPreferences:ArrayCollection =
                executeQuery("SELECT DISTINCT eventId FROM UserPreference WHERE eventId = '" + event.id + "'");
        return userPreferences && (userPreferences.length > 0);
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
        } catch (initError:SQLError) {
            throw new Error("Error selecting records from table '${jClass.as3Type.name}': " + initError.message);
        }
        return result;
    }
}
}
