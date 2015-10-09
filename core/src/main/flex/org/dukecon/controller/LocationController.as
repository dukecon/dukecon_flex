/**
 * Created by christoferdutz on 08.07.15.
 */
package org.dukecon.controller {
public class LocationController {

    [Embed(source="/locations/location1.png")]
    [Bindable]
    public var location1:Class;

    [Embed(source="/locations/location2.png")]
    [Bindable]
    public var location2:Class;

    [Embed(source="/locations/location3.png")]
    [Bindable]
    public var location3:Class;

    [Embed(source="/locations/location4.png")]
    [Bindable]
    public var location4:Class;

    protected var icons:Array = [location1, location2, location3, location4];

    public function LocationController() {
    }

    public function getIconForLocation(id:String):Class {
        /*var b:ByteArray = new ByteArray();
         b.writeMultiByte(name, "UTF-8");
         var hash:String = SHA256.computeDigest(b);
         var intHash:Number = parseInt(hash, 16);*/
        var imageIndex:int = Number(id) % icons.length;
        return icons[imageIndex];
    }

}
}

