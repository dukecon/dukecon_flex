/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {
import mx.collections.ArrayCollection;

import nz.co.codec.flexorm.EntityManager;

import org.dukecon.model.Location;

public class LocationService {

    private var em:EntityManager;

    public function LocationService() {
        em = EntityManager.instance;
    }

    public function get locations():ArrayCollection {
        return em.findAll(Location);
    }

    public function getIconForLocation(id:String):Class {
        return null;
    }

    public function getMapForLocation(id:String):Class {
        return null;
    }

    public function getLocationName(id:String, locale:String):String {
        return null;
    }

}
}
