/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {

import mx.collections.ArrayCollection;

import nz.co.codec.flexorm.EntityManager;
import nz.co.codec.flexorm.criteria.Criteria;

import org.dukecon.model.Audience;

import org.dukecon.model.Event;
import org.dukecon.model.EventType;
import org.dukecon.model.Language;
import org.dukecon.model.Location;
import org.dukecon.model.Speaker;
import org.dukecon.model.Track;

public class EventService {

    private var em:EntityManager;

    public function EventService() {
        em = EntityManager.instance;
    }

    public function getEventsForAudience(audience:Audience):ArrayCollection {
        var criteria:Criteria = em.createCriteria(Event);
        criteria.addEqualsCondition("audience.id", audience.id);
        return getEvents(criteria);
    }

    public function getEventsForEventType(eventType:EventType):ArrayCollection {
        var criteria:Criteria = em.createCriteria(Event);
        criteria.addEqualsCondition("eventType.id", eventType.id);
        return getEvents(criteria);
    }

    public function getEventsForLanguage(language:Language):ArrayCollection {
        var criteria:Criteria = em.createCriteria(Event);
        criteria.addEqualsCondition("language.id", language.id);
        return getEvents(criteria);
    }

    public function getEventsForLocation(location:Location):ArrayCollection {
        var criteria:Criteria = em.createCriteria(Event);
        criteria.addEqualsCondition("location.id", location.id);
        return getEvents(criteria);
    }

    public function getEventsForSpeaker(speaker:Speaker):ArrayCollection {
        var criteria:Criteria = em.createCriteria(Event);
        criteria.addEqualsCondition("speaker.id", speaker.id);
        return getEvents(criteria);
    }

    public function getEventsForStream(track:Track):ArrayCollection {
        var criteria:Criteria = em.createCriteria(Event);
        criteria.addEqualsCondition("track.id", track.id);
        return getEvents(criteria);
    }

    private function getEvents(criteria:Criteria):ArrayCollection {
        var res:ArrayCollection = em.fetchCriteria(criteria);
        res.filterFunction = filterPartlyInitialized;
        res.refresh();
        return res;
    }

    private static function filterPartlyInitialized(event:Event):Boolean {
        return (event.audience != null) && (event.type != null) && (event.language != null) &&
                (event.location != null) && (event.speakers != null) && (event.track != null);
    }

}
}
