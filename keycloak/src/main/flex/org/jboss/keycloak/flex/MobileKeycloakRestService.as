/**
 * Created by christoferdutz on 17.09.15.
 */
package org.jboss.keycloak.flex {
import org.jboss.keycloak.flex.event.KeycloakLoginEvent;
import org.jboss.keycloak.flex.event.SocialLoginEvent;
import org.jboss.keycloak.flex.view.KeycloakLoginView;
import org.jboss.keycloak.flex.view.SocialLoginView;

import spark.components.ViewNavigator;

public class MobileKeycloakRestService extends KeycloakRestService {

    private var _navigator:ViewNavigator;

    public function MobileKeycloakRestService() {
    }

    public function get navigator():ViewNavigator {
        return _navigator;
    }

    public function set navigator(value:ViewNavigator):void {
        _navigator = value;
    }

    override protected function handleKeycloakLogin(event:KeycloakLoginEvent):void {
        _navigator.pushView(KeycloakLoginView, event);
    }

    override protected function handleSocialLogin(event:SocialLoginEvent):void {
        // Pop the keycloak view from the stack first.
        _navigator.popView();
        // Add the social login view.
        _navigator.pushView(SocialLoginView, event);
    }

}
}
