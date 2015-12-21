/**
 * Created by christoferdutz on 28.10.15.
 */
package org.dukecon.components {
import mx.core.ScrollPolicy;

import org.dukecon.components.layouts.MobileScheduleLayout;

import spark.components.List;
import spark.components.ScrollSnappingMode;
import spark.layouts.VerticalLayout;
import spark.layouts.supportClasses.LayoutBase;

public class MobileSchedule extends List {

    public function MobileSchedule() {
        layout = getDefaultLayout();
        scrollSnappingMode = ScrollSnappingMode.LEADING_EDGE;
        setStyle("horizontalScrollPolicy", ScrollPolicy.OFF);
        useVirtualLayout = true;
    }

    protected function getDefaultLayout():LayoutBase {
        var l:VerticalLayout = new MobileScheduleLayout(this);
        l.horizontalAlign = "contentJustify";
        l.gap = 0;
        l.rowHeight = 300;
        return l;
    }

}
}
