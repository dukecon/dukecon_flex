/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {
import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;

import org.dukecon.model.ConferenceStorage;

public class SpeakerService {

    [Inject]
    public var conferenceService:ConferenceService;

    public function SpeakerService() {
    }

    public function getSpeakers(conferenceId:String):ArrayCollection {
        var conference:ConferenceStorage = conferenceService.getConference(conferenceId);
        if(conference) {
            var speakers:ArrayCollection = conference.conference.speakers;

            // Sort the speakers by last name.
            var sortField:SortField = new SortField();
            sortField.name = "lastname";
            sortField.numeric = false;
            var sort:Sort = new Sort();
            sort.fields = [sortField];
            speakers.sort = sort;
            speakers.refresh();

            return speakers;
        }
        return null;
    }

}
}
