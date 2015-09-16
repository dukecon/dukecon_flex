/**
 * Created by christoferdutz on 15.09.15.
 */
package org.jboss.keycloak.flex {
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

import mx.rpc.AsyncToken;
import mx.rpc.events.ResultEvent;
import mx.utils.StringUtil;

import org.jboss.keycloak.flex.adapter.DefaultKeycloakAdapter;
import org.jboss.keycloak.flex.adapter.KeycloakAdapter;
import org.jboss.keycloak.flex.event.KeycloakEvent;
import org.jboss.keycloak.flex.event.KeycloakLoginRequestEvent;
import org.jboss.keycloak.flex.event.SocialLoginRequestEvent;
import org.jboss.keycloak.flex.util.CookieStorage;
import org.jboss.keycloak.flex.util.KeycloakToken;

public class KeycloakRestService extends EventDispatcher {

    protected static const STATE_CALL_REST_SERVICE:int = 10;
    protected static const STATE_CONTACT_KEYCLOAK_SERVER:int = 20;
    protected static const STATE_LOGIN_AT_REST_SERVICE:int = 30;
    protected static const STATE_CALL_REST_SERVICE_AFTER_LOGIN:int = 40;

    public function KeycloakRestService() {
        super();
    }

    public function send(url:String, method:String, cookieStores:Object = null):AsyncToken {
        var token:KeycloakToken = new KeycloakToken(cookieStores);

        var keycloakAdapter:KeycloakAdapter = new DefaultKeycloakAdapter();

        var state:int = STATE_CALL_REST_SERVICE;
        token.currentUrl = url;
        var request:URLRequest = createUrlRequest(token, method);

        var loader:URLLoader = new URLLoader();
        loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function (e:HTTPStatusEvent):void {
            processHTTPStatusEvent(token, e);
        });
        loader.addEventListener(Event.COMPLETE, function (event:Event):void {
            switch (state) {
                case STATE_CALL_REST_SERVICE:
                {
                    // The requested response is returned immediately.
                    if (token.status == 200) {
                        if (token.contentType == "application/json") {
                            token.dispatchEvent(ResultEvent.createEvent(JSON.parse(loader.data), token));
                        }

                        else {
                            trace("In State: STATE_CALL_REST_SERVICE got content type: " + token.contentType);
                        }
                    }
                    // We got a redirect (assuming we are redirected to the Keycloak server.

                    else if (token.status == 302) {
                        state = STATE_CONTACT_KEYCLOAK_SERVER;
                        token.currentUrl = token.redirectUrl;
                        request = createUrlRequest(token, URLRequestMethod.GET);
                        loader.load(request);
                    }

                    else {
                        trace("In State: STATE_CALL_REST_SERVICE got return code: " + token.status);
                    }
                    break;
                }
                case STATE_CONTACT_KEYCLOAK_SERVER:
                {
                    // A login page was returned.
                    if (token.status == 200) {
                        var response:XML = keycloakAdapter.parseResponse(loader.data);
                        var manualLoginUrl:String = keycloakAdapter.getFormLoginUrlXPath(response);
                        var socialProviders:Object = keycloakAdapter.getSocialProviders(response);
                        var feedbackMessage:String = keycloakAdapter.getFeedbackMessage(response);
                        var keycloakEvent:KeycloakEvent = new KeycloakEvent(KeycloakEvent.SHOW_LOGIN_SCREEN,
                                socialProviders,
                                feedbackMessage,
                                function (event:KeycloakLoginRequestEvent):void {
                                    token.currentUrl = manualLoginUrl;
                                    request = createUrlRequest(token, URLRequestMethod.POST);
                                    var formData:URLVariables = new URLVariables();
                                    formData.username = event.username;
                                    formData.password = event.password;
                                    formData.rememberMe = "on";
                                    request.contentType = "application/x-www-form-urlencoded";
                                    request.data = formData;
                                    loader.load(request);
                                },
                                function (event:SocialLoginRequestEvent):void {
                                    // TODO: Implement this ...
                                    trace("Got social login " + event);
                                });
                        token.dispatchEvent(keycloakEvent);
                    }
                    // The redirect probably takes us back to login at the rest service as
                    // a valid Keycloak session seems to be active.
                    else if (token.status == 302) {
                        state = STATE_LOGIN_AT_REST_SERVICE;
                        token.currentUrl = token.redirectUrl;
                        request = createUrlRequest(token, URLRequestMethod.GET);
                        loader.load(request);
                    }

                    else {
                        trace("In State: STATE_CONTACT_KEYCLOAK_SERVER got return code: " + token.status);
                    }
                    break;
                }
                case STATE_LOGIN_AT_REST_SERVICE:
                {
                    if (token.status == 302) {
                        state = STATE_CALL_REST_SERVICE_AFTER_LOGIN;
                        token.currentUrl = token.redirectUrl;
                        request = createUrlRequest(token, method);
                        loader.load(request);
                    }

                    else {
                        trace("In State: STATE_LOGIN_AT_REST_SERVICE got return code: " + token.status);
                    }
                    break;
                }
                case STATE_CALL_REST_SERVICE_AFTER_LOGIN:
                {
                    // The request seems to have succeeded, so we can interpret the response.
                    if (token.status == 200) {
                        if (token.contentType == "application/json") {
                            token.dispatchEvent(ResultEvent.createEvent(JSON.parse(loader.data), token));
                        }

                        else {
                            trace("In State: STATE_CALL_REST_SERVICE_AFTER_LOGIN got content type: " + token.contentType);
                        }
                    }

                    else {
                        trace("In State: STATE_CALL_REST_SERVICE_AFTER_LOGIN got return code: " + token.status);
                    }
                    break;
                }
            }
        });
        loader.load(request);

        return token;
    }

    protected static function processHTTPStatusEvent(token:KeycloakToken, event:HTTPStatusEvent):void {
        // Save the status so we can access this in the complete event-handler.
        token.status = event.status;

        // Reset the redirectUrl. If it's a redirect request it will
        // be set to the new value.
        token.redirectUrl = null;

        var cookieStorage:CookieStorage = token.getCookieStorageForUrl(token.currentUrl);

        // Process the headers and extract redirect urls and cookies.
        for each(var header:URLRequestHeader in event.responseHeaders) {
            if (header.name == "Content-Type") {
                token.contentType = header.value.split(";")[0];
            }
            else if (header.name == "Set-Cookie") {
                var cookies:Array = header.value.split(",");
                for each(var cookie:String in cookies) {
                    var segments:Array = cookie.split(";");
                    var parts:Array = segments[0].split("=");
                    var cookieName:String = StringUtil.trim(parts[0]);
                    var cookieValue:String = StringUtil.trim(parts[1]);
                    if (cookieValue.length > 0) {
                        cookieStorage.setCookie(cookieName, cookieValue);
                    }
                    // Setting an empty value is a delete-request.
                    else {
                        cookieStorage.removeCookie(cookieName);
                    }
                }
            }
            // The header was a redirect ... so we have to save that.
            else if ((header.name == "Location") && (event.status == 302)) {
                token.redirectUrl = header.value;
            }
        }
    }

    protected static function createUrlRequest(token:KeycloakToken, method:String):URLRequest {
        var request:URLRequest = new URLRequest(token.currentUrl);
        request.method = method;

        // Prevent the automatic following of redirects, we'll handle them manually.
        request.followRedirects = false;

        // We will handle cookies manually.
        request.manageCookies = false;

        var cookieStorage:CookieStorage = token.getCookieStorageForUrl(token.currentUrl);
        if (cookieStorage.getCookies()) {
            var cookieHeader:String = "";
            var cookies:Object = cookieStorage.getCookies();
            for (var cookieName:String in cookies) {
                if (cookies.hasOwnProperty(cookieName)) {
                    var cookieValue:String = cookieStorage.getCookie(cookieName);
                    if (cookieHeader.length > 0) {
                        cookieHeader += "; ";
                    }
                    cookieHeader += cookieName + "=" + cookieValue;
                }
            }
            if (cookieHeader.length > 0) {
                request.requestHeaders = [new URLRequestHeader("Cookie", cookieHeader)];
            }
        }
        return request;
    }


}
}
