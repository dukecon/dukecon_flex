/**
 * Created by christoferdutz on 17.09.15.
 */
package org.jboss.keycloak.flex {
import mx.rpc.AsyncToken;
import mx.rpc.events.ResultEvent;

import org.jboss.keycloak.flex.event.KeycloakLoginEvent;
import org.jboss.keycloak.flex.event.SocialLoginEvent;
import org.jboss.keycloak.flex.view.KeycloakLoginView;
import org.jboss.keycloak.flex.view.SocialLoginView;

import spark.components.ViewNavigator;

public class MobileKeycloakRestService {

    private var service:KeycloakRestService;

    public function MobileKeycloakRestService() {
        service = new KeycloakRestService();
    }

    public function send(navigator:ViewNavigator, url:String, method:String, cookieStores:Object = null):AsyncToken {
        var token:AsyncToken = service.send(url, method, cookieStores);
        token.addEventListener(KeycloakLoginEvent.SHOW_LOGIN_SCREEN, function (event:KeycloakLoginEvent):void {
            navigator.pushView(KeycloakLoginView, event);
        });
        token.addEventListener(SocialLoginEvent.SHOW_SOCIAL_LOGIN_SCREEN, function(event:SocialLoginEvent):void {
            navigator.pushView(SocialLoginView, event);
        });
        token.addEventListener(ResultEvent.RESULT, function (event:ResultEvent):void {
            if((navigator.activeView is SocialLoginView) || (navigator.activeView is KeycloakLoginView)) {
                navigator.popView();
            }
        });
        return token;
    }

}
}
