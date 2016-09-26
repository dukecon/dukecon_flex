/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {
import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;

import org.dukecon.model.ConferenceStorage;

public class LocationService {

    [Inject]
    public var conferenceService:ConferenceService;

    public function LocationService() {
    }

    public function getLocations(conferenceId:String):ArrayCollection {
        var conference:ConferenceStorage = conferenceService.getConference(conferenceId);
        if(conference) {
            var res:ArrayCollection = conference.conference.metaData.locations;

            // Sort the locations by order.
            var orderSortField:SortField = new SortField();
            orderSortField.name = "order";
            orderSortField.numeric = true;
            var locationSort:Sort = new Sort();
            locationSort.fields = [orderSortField];
            res.sort = locationSort;
            res.refresh();

            return res;
        }
        return null;
    }

}
}
