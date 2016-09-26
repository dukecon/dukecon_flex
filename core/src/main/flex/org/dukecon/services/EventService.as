/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {

import mx.collections.ArrayCollection;

import org.dukecon.model.Audience;
import org.dukecon.model.ConferenceStorage;
import org.dukecon.model.EventType;
import org.dukecon.model.Language;
import org.dukecon.model.Location;
import org.dukecon.model.Speaker;
import org.dukecon.model.Track;

public class EventService {

    [Inject]
    public var conferenceService:ConferenceService;

    public function EventService() {
    }

    public function getEventsForDay(conferenceId:String, day:String):ArrayCollection {
        var conference:ConferenceStorage = conferenceService.getConference(conferenceId);
        if(conference) {
            return conference.dayIndex[day];
        }
        return null;
    }

    public function getEventsForAudience(conferenceId:String, audience:Audience):ArrayCollection {
        var conference:ConferenceStorage = conferenceService.getConference(conferenceId);
        if(conference) {
            return conference.audienceIndex[audience.id];
        }
        return null;
    }

    public function getEventsForEventType(conferenceId:String, eventType:EventType):ArrayCollection {
        var conference:ConferenceStorage = conferenceService.getConference(conferenceId);
        if(conference) {
            return conference.eventTypeIndex[eventType.id];
        }
        return null;
    }

    public function getEventsForLanguage(conferenceId:String, language:Language):ArrayCollection {
        var conference:ConferenceStorage = conferenceService.getConference(conferenceId);
        if(conference) {
            return conference.languageIndex[language.id];
        }
        return null;
    }

    public function getEventsForLocation(conferenceId:String, location:Location):ArrayCollection {
        var conference:ConferenceStorage = conferenceService.getConference(conferenceId);
        if(conference) {
            return conference.locationIndex[location.id];
        }
        return null;
    }

    public function getEventsForSpeaker(conferenceId:String, speaker:Speaker):ArrayCollection {
        var conference:ConferenceStorage = conferenceService.getConference(conferenceId);
        if(conference) {
            return conference.speakerIndex[speaker.id];
        }
        return null;
    }

    public function getEventsForStream(conferenceId:String, track:Track):ArrayCollection {
        var conference:ConferenceStorage = conferenceService.getConference(conferenceId);
        if(conference) {
            return conference.streamIndex[track.id];
        }
        return null;
    }

}
}
