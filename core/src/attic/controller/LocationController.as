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

    [Embed(source="/locations/maps/location-map-community-hall.png")]
    [Bindable]
    public var locationMapCommunityHall:Class;

    [Embed(source="/locations/maps/location-map-jug-cafe.png")]
    [Bindable]
    public var locationMapJugCafe:Class;

    [Embed(source="/locations/maps/location-map-lilaque.png")]
    [Bindable]
    public var locationMapLilaque:Class;

    [Embed(source="/locations/maps/location-map-neptun.png")]
    [Bindable]
    public var locationMapNeptun:Class;

    [Embed(source="/locations/maps/location-map-quantum-1-2.png")]
    [Bindable]
    public var locationMapQuantum1And2:Class;

    [Embed(source="/locations/maps/location-map-quantum-1.png")]
    [Bindable]
    public var locationMapQuantum1:Class;

    [Embed(source="/locations/maps/location-map-quantum-2.png")]
    [Bindable]
    public var locationMapQuantum2:Class;

    [Embed(source="/locations/maps/location-map-quantum-3.png")]
    [Bindable]
    public var locationMapQuantum3:Class;

    [Embed(source="/locations/maps/location-map-quantum-4.png")]
    [Bindable]
    public var locationMapQuantum4:Class;

    [Embed(source="/locations/maps/location-map-quantum-ug.png")]
    [Bindable]
    public var locationMapQuantumUG:Class;

    [Embed(source="/locations/maps/location-map-wintergarten.png")]
    [Bindable]
    public var locationMapSchauspielhaus:Class;

    [Embed(source="/locations/maps/location-map-neptun.png")]
    [Bindable]
    public var locationMapWintergarten:Class;

    [Embed(source="/locations/maps/location-map-ling-bao.png")]
    [Bindable]
    public var locationMapLingBao:Class;

    [Embed(source="/locations/maps/location-map-matamba.png")]
    [Bindable]
    public var locationMapMatamba:Class;

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

    public function getMapForLocation(id:String):Class {
        switch(id) {
            case "1": return locationMapWintergarten;
            case "2": return locationMapJugCafe;
            case "3": return locationMapMatamba;
            case "4": return locationMapQuantum1;
            case "5": return locationMapMatamba;
            case "6": return locationMapQuantum2;
            case "7": return locationMapLingBao;
            case "8": return locationMapLingBao;
            case "9": return locationMapSchauspielhaus;
            case "10": return locationMapQuantum1And2;
            case "11": return locationMapQuantum3;
            case "12": return locationMapQuantum4;
            case "13": return locationMapLilaque;
            case "14": return locationMapNeptun;
            case "15": return locationMapCommunityHall;
            case "16": return locationMapQuantumUG;
            default: return null;
        }
    }

}
}

