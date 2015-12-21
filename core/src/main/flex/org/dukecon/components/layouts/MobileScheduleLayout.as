/**
 * Created by christoferdutz on 28.10.15.
 */
package org.dukecon.components.layouts {
import org.dukecon.components.MobileSchedule;

import spark.layouts.VerticalLayout;

public class MobileScheduleLayout extends VerticalLayout {

    public function MobileScheduleLayout(schedule:MobileSchedule)
    {
        super();
        _schedule = schedule;
    }

    private var prevUnscaledWidth:Number;
    private var _schedule:MobileSchedule;

    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        if (prevUnscaledWidth != unscaledWidth)
        {
            prevUnscaledWidth = unscaledWidth;
        }
    }

}
}
