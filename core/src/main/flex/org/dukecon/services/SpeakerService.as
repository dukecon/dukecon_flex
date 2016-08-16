/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {
import mx.collections.ArrayCollection;

import nz.co.codec.flexorm.EntityManager;

import org.dukecon.model.Speaker;

public class SpeakerService {

    private var em:EntityManager;

    public function SpeakerService() {
        em = EntityManager.instance;
    }

    public function get speakers():ArrayCollection {
        return em.findAll(Speaker);
    }

    public function getSpeaker(id:String):Speaker {
        return null;
    }

    public function getIconForSpeaker(id:String):Class {
        return null;
    }

}
}
