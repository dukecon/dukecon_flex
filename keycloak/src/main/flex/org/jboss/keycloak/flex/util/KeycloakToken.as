/**
 * Created by christoferdutz on 15.09.15.
 */
package org.jboss.keycloak.flex.util {
import mx.rpc.AsyncToken;

public class KeycloakToken extends AsyncToken {

    private var cookieStores:Object;
    private var _contentType:String = null;
    private var _status:int = -1;
    private var _currentUrl:String = null;
    private var _redirectUrl:String = null;

    public function KeycloakToken(cookieStores:Object = null) {
        super();
        if(cookieStores) {
            this.cookieStores = cookieStores;
        } else {
            this.cookieStores = {};
        }
    }

    public function getCookieStorageForUrl(url:String):CookieStorage {
        var host:String = getHostName(url);

        if(!cookieStores.hasOwnProperty(host)) {
            cookieStores[host] = new CookieStorage();
        }
        return cookieStores[host];
    }

    public function get contentType():String {
        return _contentType;
    }

    public function set contentType(value:String):void {
        _contentType = value;
    }

    public function get status():int {
        return _status;
    }

    public function set status(value:int):void {
        _status = value;
    }

    public function get currentUrl():String {
        return _currentUrl;
    }

    public function set currentUrl(value:String):void {
        _currentUrl = value;
    }

    public function get redirectUrl():String {
        return _redirectUrl;
    }

    public function set redirectUrl(value:String):void {
        _redirectUrl = value;
    }

    protected static function getHostName(url:String):String {
        var host:String = url.substring(url.indexOf("//") + 2);
        if(host.indexOf(":") != -1) {
            return host.substring(0, host.indexOf(":"));
        } else {
            return host.substring(0, host.indexOf("/"));
        }
    }

}
}
