/**
 * Created by christoferdutz on 16.10.16.
 */
package org.dukecon.events {
import flash.events.Event;

import org.dukecon.model.Styles;

import org.dukecon.model.Styles;

public class StyleDefinitionsChangedEvent extends Event {

    public static var STYLE_DEFINITIONS_CHANGED:String = "styleDefinitionsChanged";

    private var _styles:Styles;

    public function StyleDefinitionsChangedEvent(styles:Styles, type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this._styles = styles;
    }

    public static function createStyleDefinitionsChangedEvent(styles:Styles = null):StyleDefinitionsChangedEvent {
        return new StyleDefinitionsChangedEvent(styles, STYLE_DEFINITIONS_CHANGED);
    }

    public function get styles():Styles {
        return _styles;
    }

}
}
