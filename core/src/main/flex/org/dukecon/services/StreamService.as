/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {
import mx.collections.ArrayCollection;

import nz.co.codec.flexorm.EntityManager;

import org.dukecon.model.Track;

public class StreamService {

    private var em:EntityManager;

    public function StreamService() {
        em = EntityManager.instance;
    }

    public function get streams():ArrayCollection {
        return em.findAll(Track);
    }

}
}
