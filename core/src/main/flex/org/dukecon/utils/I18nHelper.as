/**
 * Created by christoferdutz on 16.08.16.
 */
package org.dukecon.utils {
import mx.resources.ResourceManager;

public class I18nHelper {

    public static function getName(names:Object, locale:String, defaultLocale:String):String {
        var key:String = locale.substring(0, locale.indexOf("_"));
        if(names[key]) {
            return names[key];
        }
        key = defaultLocale.substring(0, locale.indexOf("_"));
        return names[key];
    }

    public function getResourceManagerCodeForLanguageCode(languageCode:String, resourceManager:ResourceManager):String {
        return null;
    }

}
}
