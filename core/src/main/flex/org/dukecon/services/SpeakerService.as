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

            // Sort the locations by order.
            var orderSortField:SortField = new SortField();
            orderSortField.name = "name";
            orderSortField.numeric = false;
            var locationSort:Sort = new Sort();
            locationSort.fields = [orderSortField];
            speakers.sort = locationSort;
            speakers.refresh();

            return speakers;
        }
        return null;
    }

}
}
