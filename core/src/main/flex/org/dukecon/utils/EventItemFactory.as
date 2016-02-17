/**
 * Created by christoferdutz on 17.02.16.
 */
package org.dukecon.utils {
import mx.collections.ArrayCollection;
import mx.core.IFactory;

import org.dukecon.itemrenderer.GridEventItemRenderer;

public class EventItemFactory implements IFactory {

    private var startTime:Number;
    private var locationIds:ArrayCollection;

    public function EventItemFactory(startTime:Number, locationIds:ArrayCollection) {
        this.startTime = startTime;
        this.locationIds = locationIds;
    }

    public function newInstance():* {
        var rect:GridEventItemRenderer = new GridEventItemRenderer();
        rect.startTime = startTime;
        rect.locationIds = locationIds;
        return rect;
    }

}
}
