/**
 * Created by christoferdutz on 15.09.15.
 */
package org.jboss.keycloak.flex.util {
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.getQualifiedClassName;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.AsyncToken;

public class KeycloakToken extends AsyncToken {

    protected static var log:ILogger = Log.getLogger(getQualifiedClassName(KeycloakToken).replace("::"));

    private var _state:int = -1;
    private var _loader:URLLoader = null;
    private var _initialMethod:String = null;
    private var _cookieStores:Object;
    private var _contentType:String = null;
    private var _status:int = -1;
    private var _currentUrl:String = null;
    private var _redirectUrl:String = null;
    private var _keycloakHost:String = null;
    private var _keycloakToken:Object = null;
    private var _selectedProvider:String = null;
    private var _etag:String = null;

    public function KeycloakToken(cookieStores:Object = null) {
        super();
        if(cookieStores) {
            this._cookieStores = cookieStores;
        } else {
            this._cookieStores = {};
        }
    }

    public function getCookieStorageForUrl(url:String):Object {
        var host:String = getHostName(url);

        if(!_cookieStores.hasOwnProperty(host)) {
            _cookieStores[host] = {};
        }
        return _cookieStores[host];
    }

    public function get state():int {
        return _state;
    }

    public function set state(value:int):void {
        _state = value;
    }
    
    public function load(request:URLRequest):void {
        if(!_loader) {
            throw new Error("No loader specified");
        }
        log.debug(" ");
        log.debug(" ");
        log.debug("----------------------------------------------------------------------");
        log.debug("-- New HTTP Request");
        log.debug("----------------------------------------------------------------------");
        log.debug("Loading = " + request.url);
        _loader.load(request);
    }
    
    public function get data():* {
        if(!_loader) {
            throw new Error("No loader specified");
        }
        return _loader.data;       
    }

    public function set loader(value:URLLoader):void {
        _loader = value;
    }

    public function get initialMethod():String {
        return _initialMethod;
    }

    public function set initialMethod(value:String):void {
        _initialMethod = value;
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

    public function get keycloakHost():String {
        return _keycloakHost;
    }

    public function set keycloakHost(value:String):void {
        _keycloakHost = value;
    }

    public function get keycloakToken():Object {
        return _keycloakToken;
    }

    public function set keycloakToken(value:Object):void {
        _keycloakToken = value;
    }

    public function get selectedProvider():String {
        return _selectedProvider;
    }

    public function set selectedProvider(value:String):void {
        _selectedProvider = value;
    }

    public function get etag():String {
        return _etag;
    }

    public function set etag(value:String):void {
        _etag = value;
    }

    public static function getHostName(url:String):String {
        var host:String = url.substring(url.indexOf("//") + 2);
        if(host.indexOf(":") != -1) {
            return host.substring(0, host.indexOf(":"));
        } else {
            return host.substring(0, host.indexOf("/"));
        }
    }

}
}
