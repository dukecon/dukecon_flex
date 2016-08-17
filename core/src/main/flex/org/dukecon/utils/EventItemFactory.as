/**
 * Created by christoferdutz on 17.02.16.
 */
package org.dukecon.utils {
import mx.collections.ArrayCollection;
import mx.core.IFactory;

import org.dukecon.itemrenderer.GridEventItemRenderer;

public class EventItemFactory implements IFactory {

    private var startTime:Number;
    private var locations:ArrayCollection;

    public function EventItemFactory(startTime:Number, locations:ArrayCollection) {
        this.startTime = startTime;
        this.locations = locations;
    }

    public function newInstance():* {
        var rect:GridEventItemRenderer = new GridEventItemRenderer();
        rect.startTime = startTime;
        rect.locations = locations;
        return rect;
    }

}
}
