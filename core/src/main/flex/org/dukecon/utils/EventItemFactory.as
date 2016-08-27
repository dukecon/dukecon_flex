/**
 * Created by christoferdutz on 17.02.16.
 */
package org.dukecon.utils {
import mx.core.IFactory;

import org.dukecon.itemrenderer.GridEventItemRenderer;
import org.dukecon.services.ResourceService;
import org.dukecon.services.UserPreferenceService;

public class EventItemFactory implements IFactory {

    private var startTime:Number;
    private var rowNum:Number;
    private var resourceService:ResourceService;
    private var userPreferenceService:UserPreferenceService;

    public function EventItemFactory(startTime:Number, rowNum:Number, resourceService:ResourceService, userPreferenceService:UserPreferenceService) {
        this.startTime = startTime;
        this.rowNum = rowNum;
        this.resourceService = resourceService;
        this.userPreferenceService = userPreferenceService;
    }

    public function newInstance():* {
        var event:GridEventItemRenderer = new GridEventItemRenderer();
        event.startTime = startTime;
        event.rowNum = rowNum;
        event.resourceService = resourceService;
        event.userPreferenceService = userPreferenceService;
        return event;
    }

}
}
