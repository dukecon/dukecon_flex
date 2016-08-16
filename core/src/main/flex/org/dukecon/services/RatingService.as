/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {
import nz.co.codec.flexorm.EntityManager;

import org.dukecon.model.Event;

public class RatingService {

    private var em:EntityManager;

    public function RatingService() {
        em = EntityManager.instance;
    }

    public function getRating(event:Event):String {
        return null;
    }

}
}
