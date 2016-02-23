/**
 * Created by christoferdutz on 15.09.15.
 */
package org.jboss.keycloak.flex {
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.ByteArray;

import mx.rpc.AsyncToken;
import mx.rpc.events.ResultEvent;
import mx.utils.Base64Decoder;
import mx.utils.StringUtil;

import org.jboss.keycloak.flex.adapter.DefaultKeycloakAdapter;
import org.jboss.keycloak.flex.adapter.KeycloakAdapter;
import org.jboss.keycloak.flex.event.KeycloakLoginEvent;
import org.jboss.keycloak.flex.event.KeycloakLoginRequestEvent;
import org.jboss.keycloak.flex.event.SocialLoginEvent;
import org.jboss.keycloak.flex.event.SocialLoginRequestEvent;
import org.jboss.keycloak.flex.util.CookieStorage;
import org.jboss.keycloak.flex.util.KeycloakToken;

public class KeycloakRestService extends EventDispatcher {

    protected static const STATE_CALL_REST_SERVICE:int = 10;
    protected static const STATE_CONTACT_KEYCLOAK_SERVER:int = 20;
    protected static const STATE_LOGIN_USING_SOCIAL_PROVIDER:int = 30;
    protected static const STATE_LOGIN_AT_REST_SERVICE:int = 40;
    protected static const STATE_CALL_REST_SERVICE_AFTER_LOGIN:int = 50;

    protected var keycloakAdapter:KeycloakAdapter;
    public var preferredProvider:String;

    public function KeycloakRestService(keycloakAdapter:KeycloakAdapter = null) {
        super();
        if(keycloakAdapter) {
            this.keycloakAdapter = keycloakAdapter;
        } else {
            this.keycloakAdapter = new DefaultKeycloakAdapter();
        }
    }

    public function send(url:String, method:String, cookieStores:Object = null):AsyncToken {
        // If a preferred provider is set and is not set to "keycloak",
        // pass the hint parameter to keycloak.
        if(preferredProvider && (preferredProvider != "keycloak")) {
            if(url.indexOf("?") != -1) {
                url += "&";
            } else {
                url += "?";
            }
            url += "kc_idp_hint=" + preferredProvider;
        }

        var token:KeycloakToken = new KeycloakToken(cookieStores);
        token.state = STATE_CALL_REST_SERVICE;
        trace("Change State to STATE_CALL_REST_SERVICE");
        token.currentUrl = url;
        token.initialMethod = method;

        var loader:URLLoader = new URLLoader();
        loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function (event:HTTPStatusEvent):void {
            onHTTPStatusEvent(token, event);
        });
        loader.addEventListener(Event.COMPLETE, function (event:Event):void {
            onHTTPCompleteEvent(token, event);
        });
        loader.addEventListener(IOErrorEvent.IO_ERROR, function (event:IOErrorEvent):void {
            trace(event);
        });
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function (event:SecurityErrorEvent):void {
            trace(event);
        });
        loader.addEventListener(ErrorEvent.ERROR, function (event:ErrorEvent):void {
            trace(event);
        });
        token.loader = loader;

        var request:URLRequest = createUrlRequest(token, method);
        token.load(request);

        return token;
    }

    protected static function onHTTPStatusEvent(token:KeycloakToken, event:HTTPStatusEvent):void {
        // Save the status so we can access this in the complete event-handler.
        token.status = event.status;

        // Reset the redirectUrl. If it's a redirect request it will
        // be set to the new value.
        token.redirectUrl = null;

        var cookieStorage:CookieStorage = token.getCookieStorageForUrl(token.currentUrl);

        // Process the headers and extract redirect urls and cookies.
        trace("--------------------------------------------");
        trace("Headers:");
        trace("--------------------------------------------");
        for each(var header:URLRequestHeader in event.responseHeaders) {
            trace(" - " + header.name + "=" + header.value);
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
                        if ("KEYCLOAK_IDENTITY" == cookieName) {
                            // Here the user id is encoded in the keycloak servers
                            // cookie stores KEYCLOAK_IDENTITY cookie. Decode with http://jwt.io/
                            // JavaScript implementation at https://github.com/auth0/jwt-decode
                            var tokenParts:Array = cookieValue.split(".");
                            var decoder:Base64Decoder = new Base64Decoder();
                            var encodedToken:String = tokenParts[1];
                            switch (encodedToken.length % 4) {
                                case 0:
                                    break;
                                case 2:
                                    encodedToken += "==";
                                    break;
                                case 3:
                                    encodedToken += "=";
                                    break;
                                default:
                                    throw new Error("Illegal base64url string!");
                            }
                            decoder.decode(encodedToken);
                            try {
                                var decodedByteArray:ByteArray = decoder.toByteArray();
                            } catch(e:Error) {
                                trace(e);
                            }
                            var decodedToken:String = decodedByteArray.toString();
                            token.keycloakToken = JSON.parse(decodedToken);
                        }
                    }
                    // Setting an empty value is a delete-request.
                    else {
                        cookieStorage.removeCookie(cookieName);
                    }
                }
            }
            // The header was a redirect ... so we have to save that.
            else if ((header.name == "Location") && ((event.status == 302) || (event.status == 307))) {
                token.redirectUrl = header.value;
            }
        }
        trace("--------------------------------------------");
    }

    protected function onHTTPCompleteEvent(token:KeycloakToken, event:Event):void {
        var request:URLRequest;
        trace("State = " + token.status);
        if((token.status == 302) || (token.status == 307)) {
            trace("Redirect-To = " + token.redirectUrl);
        }
        switch (token.state) {
            case STATE_CALL_REST_SERVICE:
            {
                // The requested response is returned immediately.
                if (token.status == 200) {
                    if (token.contentType == "application/json") {
                        trace("Got normal response from service");
                        token.dispatchEvent(ResultEvent.createEvent(JSON.parse(token.data), token));
                    }

                    else {
                        trace("In State: STATE_CALL_REST_SERVICE got content type: " + token.contentType);
                    }
                }
                // We got a redirect (assuming we are redirected to the Keycloak server.

                else if (token.status == 302) {
                    token.state = STATE_CONTACT_KEYCLOAK_SERVER;
                    trace("Change State to STATE_CONTACT_KEYCLOAK_SERVER");
                    token.currentUrl = token.redirectUrl;
                    request = createUrlRequest(token, URLRequestMethod.GET);
                    token.load(request);
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
                    token.keycloakHost = KeycloakToken.getHostName(token.currentUrl);
                    var response:XML = keycloakAdapter.parseResponse(token.data);
                    var manualLoginUrl:String = keycloakAdapter.getFormLoginUrlXPath(response);
                    // If "keycloak" is the preferred provider, we simply omit all social providers.
                    var socialProviders:Object = (preferredProvider != "keycloak") ?
                            keycloakAdapter.getSocialProviders(response) : {};
                    var feedbackMessage:String = keycloakAdapter.getFeedbackMessage(response);
                    var keycloakEvent:KeycloakLoginEvent = new KeycloakLoginEvent(KeycloakLoginEvent.SHOW_LOGIN_SCREEN,
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
                                token.load(request);
                                token.selectedProvider = "keycloak"
                            },
                            function (event:SocialLoginRequestEvent):void {
                                token.state = STATE_LOGIN_USING_SOCIAL_PROVIDER;
                                trace("Change State to STATE_LOGIN_USING_SOCIAL_PROVIDER");
                                // If this is a relative url, we have to add the protocol and host part
                                // of the currently active page.
                                if (event.providerUrl.charAt(0) == '/') {
                                    var currentHost:String = token.currentUrl.substr(0, token.currentUrl.indexOf("/", token.currentUrl.indexOf("//") + 2));
                                    token.currentUrl = currentHost + event.providerUrl;
                                } else {
                                    token.currentUrl = event.providerUrl;
                                }
                                request = createUrlRequest(token, URLRequestMethod.GET);
                                token.load(request);
                                var provider:String = token.currentUrl.substr(token.currentUrl.indexOf("/broker/") + 8);
                                provider = provider.substr(0, provider.indexOf("/"));
                                token.selectedProvider = provider;
                            });
                    handleKeycloakLogin(keycloakEvent);
                }
                // The redirect probably takes us back to login at the rest service as
                // a valid Keycloak session seems to be active.
                else if (token.status == 302) {
                    token.state = STATE_LOGIN_AT_REST_SERVICE;
                    trace("Change State to STATE_LOGIN_AT_REST_SERVICE");
                    token.currentUrl = token.redirectUrl;
                    request = createUrlRequest(token, URLRequestMethod.GET);
                    token.load(request);
                }
                // If a preferred provider was specified, we might be directly redirected
                // to the social provider login.
                else if (token.status == 307) {
                    token.state = STATE_LOGIN_USING_SOCIAL_PROVIDER;
                    trace("Change State to STATE_LOGIN_USING_SOCIAL_PROVIDER");
                    token.currentUrl = token.redirectUrl;
                    request = createUrlRequest(token, URLRequestMethod.GET);
                    token.load(request);
                    var provider:String = token.currentUrl.substr(token.currentUrl.indexOf("/broker/") + 8);
                    provider = provider.substr(0, provider.indexOf("/"));
                    token.selectedProvider = provider;
                }
                // We get an 500 error, if a provider is selected that no longer exists or
                // never existed (This condition is rather unspecific).
                else if ((token.status == 500) && preferredProvider) {
                    // TODO: Implement something ...
                }
                else {
                    trace("In State: STATE_CONTACT_KEYCLOAK_SERVER got return code: " + token.status);
                }
                break;
            }
            case STATE_LOGIN_USING_SOCIAL_PROVIDER:
            {
                if ((token.status == 302) || (token.status == 307)) {
                    handleSocialLogin(new SocialLoginEvent(SocialLoginEvent.SHOW_SOCIAL_LOGIN_SCREEN,
                            token.keycloakHost, token.redirectUrl, function (redirectUrl:String):void {
                                token.state = STATE_CONTACT_KEYCLOAK_SERVER;
                                trace("Change State to STATE_CONTACT_KEYCLOAK_SERVER");
                                token.currentUrl = redirectUrl;
                                request = createUrlRequest(token, URLRequestMethod.GET);
                                token.load(request);
                            }));
                }

                else {
                    trace("In State: STATE_LOGIN_USING_SOCIAL_PROVIDER got return code: " + token.status);
                }
                break;
            }
            case STATE_LOGIN_AT_REST_SERVICE:
            {
                if (token.status == 302) {
                    token.state = STATE_CALL_REST_SERVICE_AFTER_LOGIN;
                    trace("Change State to STATE_CALL_REST_SERVICE_AFTER_LOGIN");
                    token.currentUrl = token.redirectUrl;
                    request = createUrlRequest(token, token.initialMethod);
                    token.load(request);
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
                        token.dispatchEvent(ResultEvent.createEvent(JSON.parse(token.data), token));
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
    }

    protected function handleKeycloakLogin(event:KeycloakLoginEvent):void {
        throw new Error("This method must be implemented in sub-type.");
    }

    protected function handleSocialLogin(event:SocialLoginEvent):void {
        throw new Error("This method must be implemented in sub-type.");
    }

    protected function createUrlRequest(token:KeycloakToken, method:String):URLRequest {
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
