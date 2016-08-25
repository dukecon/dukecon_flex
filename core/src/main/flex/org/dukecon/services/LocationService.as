/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {
import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;

import nz.co.codec.flexorm.EntityManager;

import org.dukecon.model.Location;

public class LocationService {

    private var em:EntityManager;

    public function LocationService() {
        em = EntityManager.instance;
    }

    public function get locations():ArrayCollection {
        var res:ArrayCollection = em.findAll(Location);

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

}
}
