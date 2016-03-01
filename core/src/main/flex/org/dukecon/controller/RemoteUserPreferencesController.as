/**
 * Created by christoferdutz on 31.08.15.
 */
package org.dukecon.controller {
import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
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

import org.dukecon.model.user.UserPreference;
import org.dukecon.utils.DukeconKeycloakAdapter;
import org.jboss.keycloak.flex.MobileKeycloakRestService;
import org.jboss.keycloak.flex.event.ProviderChangedEvent;

import spark.components.ViewNavigator;

[Event(type="org.dukecon.events.UserPreferenceDataChangedEvent", name="userPreferenceDataChanged")]
[ManagedEvents("userPreferenceDataChanged")]
public class RemoteUserPreferencesController extends EventDispatcher implements UserPreferencesController {

    protected static var log:ILogger = Log.getLogger(getQualifiedClassName(LocalUserPreferencesController).replace("::", "."));

    private var settings:SharedObject;
    private var restService:MobileKeycloakRestService;

    private var uncommittedAdditions:ArrayCollection = new ArrayCollection();
    private var uncommittedDeletes:ArrayCollection = new ArrayCollection();

    public var baseUrl:String;
    
    public var infoPopupDisplayed:Boolean = false;

    public function RemoteUserPreferencesController() {
        settings = SharedObject.getLocal("user-preference-settings");
        if(!settings.data.cookieStore) {
            settings.data.cookieStore = {};
        }
    }
    
    public function set navigator(value:ViewNavigator):void {
        restService.navigator = value;
    }

    [Init]
    public function init():void {
        restService = new MobileKeycloakRestService(new DukeconKeycloakAdapter(), true);
        restService.addEventListener(ProviderChangedEvent.PROVIDER_CHANGED, function(event:ProviderChangedEvent):void {
            dispatchEvent(new ProviderChangedEvent(ProviderChangedEvent.PROVIDER_CHANGED, event.provider));
        });
    }

    public function list():ArrayCollection {
        var userPreferences:ArrayCollection = new ArrayCollection();
        var token:AsyncToken = restService.send(baseUrl + "/rest/preferences", HTTPRequestMessage.GET_METHOD);
        token.addEventListener(ResultEvent.RESULT, function (event:ResultEvent):void {
            // Persist any changes to the cookie store.
            flushSharedObject(settings);

            // Add the user preference object to a temp list in order to 
            // add them all together, which will prevent a lot of update
            // events from being fired for every single addition.
            var tmpUserPreferences:Array = [];
            var result:Object = event.result;
            for each(var eventId:String in result) {
                var userPreference:UserPreference = new UserPreference();
                userPreference.eventId = eventId;
                userPreference.version = 0;
                tmpUserPreferences.push(userPreference);
            }
            
            // Update the original array collection.
            userPreferences.source = tmpUserPreferences;
        });
        token.addEventListener(FaultEvent.FAULT, onFault);
        
        // This will return an empty array collection, which is then filled as 
        // the data comes in.
        return userPreferences;
    }

    public function replaceAll(userPreferences:ArrayCollection):void {
        // Convert the list of UserPreference objects to an Array of ids.
        var payload:Array = [];
        for each(var userPreference:UserPreference in userPreferences) {
            payload.push(userPreference.eventId);
        }
        var token:AsyncToken = restService.send(baseUrl + "/rest/preferences", HTTPRequestMessage.POST_METHOD, payload);
        token.addEventListener(FaultEvent.FAULT, onFault);
    }

    public function add(userPreference:UserPreference):void {
        // Add the user preference to a uncommitted changes list from
        // which it is removed as soon as the write method was successful.
        if (!uncommittedAdditions.contains(userPreference)) {
            uncommittedAdditions.addItem(userPreference);
        }

        var token:AsyncToken = restService.send(baseUrl + "/rest/preferences", HTTPRequestMessage.PUT_METHOD,
                userPreference);
        token.addEventListener(ResultEvent.RESULT, function (event:ResultEvent):void {
            if (!uncommittedAdditions.contains(userPreference)) {
                uncommittedAdditions.removeItem(userPreference);
            }
        });
        token.addEventListener(FaultEvent.FAULT, onFault);
    }

    public function del(userPreference:UserPreference):void {
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

        var token:AsyncToken = restService.send(baseUrl + "/rest/preferences", HTTPRequestMessage.DELETE_METHOD,
                userPreference);
        token.addEventListener(ResultEvent.RESULT, function (event:ResultEvent):void {
            if (!uncommittedDeletes.contains(userPreference)) {
                uncommittedDeletes.removeItem(userPreference);
            }
        });
        token.addEventListener(FaultEvent.FAULT, onFault);
    }

    [Bindable("providerChanged")]
    public function get provider():String {
        return restService.provider;
    }
    
    [Bindable("connectionStateChanged")]
    public function get connectedToRemote():Boolean {
        return (restService.provider != null);
    }

    public function logout():void {
        restService.reset();
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

   protected static function flushSharedObject(so:SharedObject):void {
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

    private static function onFlushStatus(event:NetStatusEvent):void {
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
