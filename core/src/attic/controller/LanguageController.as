/**
 * Created by christoferdutz on 10.10.15.
 */
package org.dukecon.controller {
public class LanguageController {

    [Embed(source="/languages/en.png")]
    [Bindable]
    public var en:Class;

    [Embed(source="/languages/de.png")]
    [Bindable]
    public var de:Class;

    [Embed(source="/languages/deen.png")]
    [Bindable]
    public var deen:Class;

    public function LanguageController() {
    }

    public function getIconForLanguage(id:String):Class {
        if(id == "en") {
            return en;
        } else if(id == "de") {
            return de;
        } else if(id == "germanenglish") {
            return deen;
        } else {
            return null;
        }
    }

}
}
