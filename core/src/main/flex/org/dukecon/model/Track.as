/**
 * Generated by Gas3 v3.1.0 (Granite Data Services).
 *
 * NOTE: this file is only generated if it does not exist. You may safely put
 * your custom code here.
 */

package org.dukecon.model {

    [RemoteClass(alias="org.dukecon.model.Track")]
    public class Track extends TrackBase {

        private var _conference:Conference;

        public function Track() {
            super();
        }

        public function get conference():Conference {
            return _conference;
        }

        public function set conference(value:Conference):void {
            _conference = value;
        }

    }
}