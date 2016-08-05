/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {
import mx.collections.ArrayCollection;

import org.dukecon.model.Speaker;

public class SpeakerService {

    public var speakers:ArrayCollection;

    public function SpeakerService() {
    }

    public function getSpeaker(id:String):Speaker {
        return null;
    }

    public function getIconForSpeaker(id:String):Class {
        return null;
    }

}
}
