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
import org.dukecon.model.Audience;
import org.dukecon.model.Conference;
import org.dukecon.model.Event;
import org.dukecon.model.EventType;
import org.dukecon.model.Language;
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
        for each(var conference:Conference in resultEvent.result) {
            var em:EntityManager = EntityManager.instance;
            for each(var audience:Audience in conference.audiences) {
                em.save(audience);
            }
            for each(var eventType:EventType in conference.eventTypes) {
                em.save(eventType);
            }
            for each(var language:Language in conference.languages) {
                em.save(language);
            }
            for each(var location:Location in conference.locations) {
                em.save(location);
            }
            for each(var speaker:Speaker in conference.speakers) {
                em.save(speaker);
            }
            for each(var track:Track in conference.tracks) {
                em.save(track);
            }
            for each(var event:Event in conference.events) {
                em.save(event);
            }
            em.save(conference);
        }
    }

    private function onFault(event:FaultEvent):void {
        trace(event);
    }

}
}
