/**
 * Created by christoferdutz on 08.07.15.
 */
package org.dukecon.controller {
import flash.utils.ByteArray;

import mx.utils.SHA256;

public class SpeakerController {

    [Embed(source="/speakers/speaker1.png")]
    [Bindable]
    public var speaker1:Class;

    [Embed(source="/speakers/speaker2.png")]
    [Bindable]
    public var speaker2:Class;

    [Embed(source="/speakers/speaker3.png")]
    [Bindable]
    public var speaker3:Class;

    [Embed(source="/speakers/speaker4.png")]
    [Bindable]
    public var speaker4:Class;

    [Embed(source="/speakers/speaker5.png")]
    [Bindable]
    public var speaker5:Class;

    [Embed(source="/speakers/speaker6.png")]
    [Bindable]
    public var speaker6:Class;

    [Embed(source="/speakers/speaker7.png")]
    [Bindable]
    public var speaker7:Class;

    protected var icons:Array = [speaker1, speaker2, speaker3, speaker4, speaker5, speaker6, speaker7];

    public function SpeakerController() {
    }

    public function getIconForSpeaker(id:String):Class {
        var b:ByteArray = new ByteArray();
        b.writeMultiByte(id, "UTF-8");
        var hash:String = SHA256.computeDigest(b);
        var imageIndex:int = parseInt(hash, 16) % icons.length;
        return icons[imageIndex];
    }

}
}

