/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {
import org.dukecon.model.Event;

public class RatingService {

    [Inject]
    public var conferenceService:ConferenceService;

    public function RatingService() {
    }

    public function getRating(event:Event):String {
        return null;
    }

}
}
