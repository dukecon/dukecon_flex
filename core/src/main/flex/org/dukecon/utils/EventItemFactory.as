/**
 * Created by christoferdutz on 17.02.16.
 */
package org.dukecon.utils {
import mx.core.IFactory;

import org.dukecon.itemrenderer.GridEventItemRenderer;
import org.dukecon.services.ResourceService;

public class EventItemFactory implements IFactory {

    private var startTime:Number;
    private var rowNum:Number;
    private var resourceService:ResourceService;

    public function EventItemFactory(startTime:Number, rowNum:Number, resourceService:ResourceService) {
        this.startTime = startTime;
        this.rowNum = rowNum;
        this.resourceService = resourceService;
    }

    public function newInstance():* {
        var event:GridEventItemRenderer = new GridEventItemRenderer();
        event.startTime = startTime;
        event.rowNum = rowNum;
        event.resourceService = resourceService;
        return event;
    }

}
}
