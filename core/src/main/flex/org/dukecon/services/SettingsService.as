/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {
import nz.co.codec.flexorm.EntityManager;

public class SettingsService {

    private var em:EntityManager;

    public function SettingsService() {
        em = EntityManager.instance;
    }

    public static function get selectedLanguage():String {
        return "de_DE";
    }

}
}
