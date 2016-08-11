/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {

import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

import nz.co.codec.flexorm.EntityManager;

import org.dukecon.fpa.FpaEntityManager;
import org.dukecon.model.Conference;
import org.dukecon.model.Location;
import org.dukecon.model.Speaker;
import org.dukecon.model.Track;

public class ConferenceService extends EventDispatcher {

    public var selectedConference:Conference;

    private var service:RemoteObject;

    [Inject]
    public var entityManager:FpaEntityManager;
    [Inject]
    public var serverConnection:ServerConnection;

    public function ConferenceService() {
        service = new RemoteObject("conferenceService");
    }

    [Init]
    public function init():void {
        // Prepare the remote service.
        service.channelSet = serverConnection.connection;

        service.list.addEventListener(ResultEvent.RESULT, onListResult);
        service.addEventListener(FaultEvent.FAULT, onFault);
    }

    public function update():void {
        service.list();
    }

    public function get lastUpdatedDate():Date {
        return new Date();
    }

    public function getEventsForDay(day:String):ArrayCollection {
        return null;
    }

    public function getEventsForStream(stream:Track):ArrayCollection {
        return null;
    }

    public function getEventsForLocation(location:Location):ArrayCollection {
        return null;
    }

    public function getEventsForSpeaker(speaker:Speaker):ArrayCollection {
        return null;
    }

    private function onListResult(resultEvent:ResultEvent):void {
        var em:EntityManager = EntityManager.instance;
        for each(var conference:Conference in resultEvent.result) {
            em.save(conference);
        }
    }

    private function onFault(event:FaultEvent):void {
        trace(event);
    }

}
}
