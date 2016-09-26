/**
 * Created by christoferdutz on 27.08.16.
 */
package org.dukecon.services {
import org.dukecon.model.Event;

public class UserPreferenceService {


    public function UserPreferenceService() {
    }

    public function isEventSelected(event:Event):Boolean {
/*        var selectionCriteria:Criteria = em.createCriteria(UserPreference);
        selectionCriteria.addEqualsCondition("eventId", event.id);
        var selections:ArrayCollection = em.fetchCriteria(selectionCriteria);
        return selections && (selections.length > 0);*/
        return false;
    }

    public function selectEvent(event:Event):void {
/*        var eventSelection:UserPreference = new UserPreference();
        eventSelection.id = UIDUtil.createUID();
        eventSelection.eventId = event.id;
        em.save(eventSelection);*/
    }

    public function unselectEvent(event:Event):void {
/*        var selectionCriteria:Criteria = em.createCriteria(UserPreference);
        selectionCriteria.addEqualsCondition("eventId", event.id);
        var selections:ArrayCollection = em.fetchCriteria(selectionCriteria);

        if(selections && (selections.length > 0)) {
            for each(var eventSelection:UserPreference in selections) {
                em.remove(eventSelection);
            }
        }*/
    }

}
}
