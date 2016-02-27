/**
 * Created by christoferdutz on 31.08.15.
 */
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
import mx.logging.ILogger;
import mx.logging.Log;
import mx.messaging.messages.HTTPRequestMessage;
import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import org.dukecon.events.UserPreferenceDataChangedEvent;
import org.dukecon.model.Event;
import org.dukecon.model.user.UserPreference;
import org.dukecon.model.user.UserPreferenceBase;
import org.dukecon.utils.DukeconKeycloakAdapter;
import org.jboss.keycloak.flex.MobileKeycloakRestService;
import org.jboss.keycloak.flex.event.ProviderChangedEvent;
import org.jboss.keycloak.flex.util.KeycloakToken;

import spark.components.ViewNavigator;

[Event(type="org.dukecon.events.UserPreferenceDataChangedEvent", name="userPreferenceDataChanged")]
[ManagedEvents("userPreferenceDataChanged")]
public class UserPreferenceController extends EventDispatcher {

    protected static var log:ILogger = Log.getLogger(getQualifiedClassName(UserPreferenceController).replace("::", "."));

    private var preferenceSettings:SharedObject;
    private var getService:MobileKeycloakRestService;
//    private var addService:MobileKeycloakRestService;
//    private var removeService:MobileKeycloakRestService;

    private var conn:SQLConnection;
    private var db:File;

    private var uncommittedAdditions:ArrayCollection = new ArrayCollection();
    private var uncommittedDeletes:ArrayCollection = new ArrayCollection();

    public var baseUrl:String;

    public function UserPreferenceController() {
        preferenceSettings = SharedObject.getLocal("preference-settings");
        if(!preferenceSettings.data.cookieStore) {
            preferenceSettings.data.cookieStore = {};
        }
    }

    [Init]
    public function init():void {
        getService = new MobileKeycloakRestService(new DukeconKeycloakAdapter());
        getService.addEventListener(ProviderChangedEvent.PROVIDER_CHANGED, function(event:ProviderChangedEvent) {
            dispatchEvent(new ProviderChangedEvent(ProviderChangedEvent.PROVIDER_CHANGED, event.provider));
        });
        //getService.preferredProvider = "keycloak";
        //getService.preferredProvider = "github";
        //getService.preferredProvider = "google";
        //getService.preferredProvider = "twitter";

        /*        addService = new MobileKeycloakRestService(new DukeconKeycloakAdapter());
         addService.contentType = "application/json";
         addService.method = HTTPRequestMessage.POST_METHOD;
         addService.url = baseUrl + "/rest/preferences?_method=PUT";

         removeService = new MobileKeycloakRestService(new DukeconKeycloakAdapter());
         removeService.contentType = "application/json";
         removeService.method = HTTPRequestMessage.POST_METHOD;
         removeService.url = baseUrl + "/rest/preferences?_method=DELETE";
         */
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
    
    [Bindable("providerChanged")]
    public function get provider():String {
        return getService.provider;
    }
    
    public function reset():void {
        getService.reset();
    }

    public function readUserPreferences(navigator:ViewNavigator):AsyncToken {
        getService.navigator = navigator;
        var token:AsyncToken = getService.send(baseUrl + "/rest/preferences", HTTPRequestMessage.GET_METHOD);
        token.addEventListener(ResultEvent.RESULT, function (event:ResultEvent):void {
            // Persist any changes to the cookie store.
            flushSharedObject(preferenceSettings);

            var result:Object = event.result;

            var clientId:String;
            if(KeycloakToken(token).keycloakToken) {
                clientId = KeycloakToken(token).keycloakToken['sub'];
            }
            if(clientId) {
                log.debug("ClientId: " + clientId);
                // Flush the table and add each user preference returned by the server.
                UserPreferenceBase.clearTable(conn);
                var selectedEventIds:ArrayCollection = new ArrayCollection();
                for each(var obj:Object in result as Array) {
                    var userPreference:UserPreference = new UserPreference(obj);
                    userPreference.persist(conn);
                    selectedEventIds.addItem(userPreference.eventId);
                }
                log.info("Got: " + result.length + " preferences.");

                // If there are outstanding creations or deletions, replay them now.
                if (uncommittedAdditions.length > 0) {
                    log.debug("Replaying uncommitted additions:");
                    for each(var addition:UserPreference in uncommittedAdditions) {
                        // Only re-send the addition if the event was not
                        // selected, as it could have been added by another
                        // client.
                        if (!selectedEventIds.contains(addition.eventId)) {
                            addUserPreference(addition);
                        }
                    }
                    log.debug("Done replaying uncommitted additions.");
                }
                if (uncommittedDeletes.length > 0) {
                    log.debug("Replaying uncommitted deletions:");
                    for each(var deletion:UserPreference in uncommittedDeletes) {
                        // Only re-send the deletion if the event was still
                        // selected, as it could have been removed by another
                        // client.
                        if (selectedEventIds.contains(addition.eventId)) {
                            deleteUserPreference(deletion);
                        }
                    }
                    log.debug("Done replaying uncommitted deletions.");
                }

                dispatchEvent(new UserPreferenceDataChangedEvent(
                        UserPreferenceDataChangedEvent.USER_PREFERENCE_DATA_CHANGED));
            }
        });
        return token;
    }

    public function addUserPreference(userPreference:UserPreference):void {
        // Add the user preference to a uncommitted changes list from
        // which it is removed as soon as the write method was successful.
        if (!uncommittedAdditions.contains(userPreference)) {
            uncommittedAdditions.addItem(userPreference);
        }
    }

    public function deleteUserPreference(userPreference:UserPreference):void {
        // If the user preference was located in the list of uncommitted
        // additions, it's safe to remove it from that list.
        if (uncommittedAdditions.contains(userPreference)) {
            uncommittedAdditions.removeItem(userPreference);
        }
        // Add the user preference to a uncommitted changes list from
        // which it is removed as soon as the write method was successful.
        if (!uncommittedDeletes.contains(userPreference)) {
            uncommittedDeletes.addItem(userPreference);
        }
    }

    protected function onFault(fault:FaultEvent):void {
        var userPreference:UserPreference = UserPreference(fault.token.userPreference);

        // This is usually returned if we try to add something, that already there.
        // The only time this should happen, is if the same item had been added
        // by a different client. So it's safe to ignore the error response.
        if (fault.statusCode == 409) {
            uncommittedAdditions.removeItem(userPreference);
            log.debug("Added (duplicate): " + userPreference.eventId);
        }
        // This is usually returned if we try to remove something, that's not there.
        // The only time this should happen, is if the same item had been removed
        // by a different client. So it's safe to ignore the error response.
        else if (fault.statusCode == 404) {
            uncommittedDeletes.removeItem(userPreference);
            log.debug("Removed (non-existent): " + userPreference.eventId);
        }
        // In all other cases something went wrong, so let's at least log it.
        else {
            log.error("Something went wrong:" + fault.message);
        }
    }

    public function get userPreferences():ArrayCollection {
        var events:ArrayCollection = UserPreferenceBase.select(conn);
        return events;
    }

    public function isEventSelected(event:Event):Boolean {
        if (!event) return false;
        var userPreferences:ArrayCollection =
                executeQuery("SELECT DISTINCT eventId FROM UserPreference WHERE eventId = '" + event.id + "'");
        return userPreferences && (userPreferences.length > 0);
    }

    public function selectEvent(event:Event):void {
        if (!event) return;
        var userPreference:UserPreference = new UserPreference();
        userPreference.eventId = event.id;
        userPreference.version = 0;
        userPreference.persist(conn);

        // Write the preferences back to the server.
        addUserPreference(userPreference);
    }

    public function unselectEvent(event:Event):void {
        if (!event) return;
        var userPreferences:ArrayCollection = UserPreferenceBase.select(conn, "eventId = " + event.id);
        if (userPreferences != null) {
            executeQuery("DELETE FROM UserPreference WHERE eventId = '" + event.id + "'");

            // Write the preferences back to the server.
            deleteUserPreference(userPreferences[0]);
        }
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
    }

}
}
