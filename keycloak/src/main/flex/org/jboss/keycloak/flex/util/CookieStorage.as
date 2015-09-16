/**
 * Created by christoferdutz on 15.09.15.
 */
package org.jboss.keycloak.flex.util {
public class CookieStorage {

    private var _cookies:Object;

    public function CookieStorage() {
        _cookies = {};
    }

    public function setCookie(name:String, value:String):void {
        _cookies[name] = value;
    }

    public function getCookie(name:String):String {
        return _cookies[name];
    }

    public function removeCookie(name:String):void {
        delete _cookies[name];
    }

    public function getCookies():Object {
        return _cookies;
    }

}
}
