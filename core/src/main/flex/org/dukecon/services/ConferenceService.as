/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {

import flash.errors.SQLError;
import flash.events.EventDispatcher;
import flash.utils.getQualifiedClassName;

import mx.collections.ArrayCollection;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

import nz.co.codec.flexorm.EntityManager;

import org.dukecon.events.ConferenceDataChangedEvent;
import org.dukecon.model.Conference;
import org.dukecon.utils.SqlHelper;

[Event(name="conferenceDataChanged", type="org.dukecon.events.ConferenceDataChangedEvent")]
public class ConferenceService extends EventDispatcher {

    protected static var log:ILogger = Log.getLogger(getQualifiedClassName(ConferenceService).replace("::"));

    private var service:RemoteObject;
    private var em:EntityManager;

    [Inject]
    public var serverConnection:ServerConnection;

    private var _lastUpdateDate:Date;

    public function ConferenceService() {
        service = new RemoteObject("conferenceService");
        em = EntityManager.instance;
    }

    [Init]
    public function init():void {
        // Prepare the remote service.
        service.channelSet = serverConnection.connection;

        service.list.addEventListener(ResultEvent.RESULT, onListResult);
        service.addEventListener(FaultEvent.FAULT, onFault);
    }

    public function update():void {
        log.info("Updating conferences");
        service.list();
    }

    public function getDaysForConference(conference:Conference):ArrayCollection {
        var result:Object = em.query("SELECT distinct(strftime('%Y-%m-%d', start)) AS day FROM events ORDER BY day ASC");
        var days:ArrayCollection = new ArrayCollection();
        for each(var resultItem:Object in result) {
            days.addItem(resultItem["day"]);
        }
        return days;
    }

    [Bindable("conferenceDataChanged")]
    public function get lastUpdatedDate():Date {
        if(!_lastUpdateDate) {
            updateLastUpdatedDate();
        }
        return _lastUpdateDate;
    }

    private function onListResult(resultEvent:ResultEvent):void {
        log.info("Got response");
        for each(var conference:Conference in resultEvent.result) {
            try {
                em.save(conference);
                log.info("Saved Conference with id: " + conference.id);
            } catch (e:Error) {
                log.error("Got error saving conference with id: " + conference.id, e);
            }
        }
        updateLastUpdatedDate();
    }

    private static function onFault(event:FaultEvent):void {
        log.error("Got error loading conferences.", event.fault);
    }

    protected function updateLastUpdatedDate():void {
        var query:String = "SELECT max(updated_at) AS last_update_date FROM (SELECT updated_at FROM audiences " +
                "UNION SELECT updated_at FROM conferences " +
                "UNION SELECT updated_at FROM event_types " +
                "UNION SELECT updated_at FROM events " +
                "UNION SELECT updated_at FROM languages " +
                "UNION SELECT updated_at FROM locations " +
                "UNION SELECT updated_at FROM meta_datas " +
                "UNION SELECT updated_at FROM speakers " +
                "UNION SELECT updated_at FROM tracks)";

        var newLastUpdateDate:Date = null;
        try {
            var res:Array = em.query(query) as Array;
            newLastUpdateDate = SqlHelper.convertSqlDateToFlexDate(res[0].last_update_date);
        } catch(e:SQLError) {
            // Ignore
        }

        // No last update date found, fetch something from the server.
        if(!newLastUpdateDate) {
            update();
        }
        // Only update the value and fire events, if the date has changed.
        else if(_lastUpdateDate != newLastUpdateDate) {
            _lastUpdateDate = newLastUpdateDate;
            dispatchEvent(ConferenceDataChangedEvent.createConferenceDataChangedEvent());
        }
    }

}
}
