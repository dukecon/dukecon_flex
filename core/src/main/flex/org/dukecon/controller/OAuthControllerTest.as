/**
 * Created by christoferdutz on 31.08.15.
 */
package org.dukecon.controller {

import com.adobe.protocols.oauth2.OAuth2;
import com.adobe.protocols.oauth2.event.GetAccessTokenEvent;
import com.adobe.protocols.oauth2.grant.AuthorizationCodeGrant;
import com.adobe.protocols.oauth2.grant.IGrantType;

import flash.media.StageWebView;

import org.as3commons.logging.setup.LogSetupLevel;

public class OAuthControllerTest {

    public function OAuthControllerTest(stageWebView:StageWebView) {
        // set up the call
        var oauth2:OAuth2 = new OAuth2("http://keycloak.dukecon.org/auth/realms/dukecon-latest/protocol/openid-connect/auth",
                "http://keycloak.dukecon.org/auth/realms/dukecon-latest/protocol/openid-connect/token", LogSetupLevel.ALL);
        var grant:IGrantType = new AuthorizationCodeGrant(stageWebView,
                "flex",
                "40a116ed-d97e-4a0d-8400-877fa58cbf99",
                "http://my-local-flex-app/xxx",
                "");

        // make the call
        oauth2.addEventListener(GetAccessTokenEvent.TYPE, onGetAccessToken);
        oauth2.getAccessToken(grant);

        function onGetAccessToken(getAccessTokenEvent:GetAccessTokenEvent):void {
            if (getAccessTokenEvent.errorCode == null && getAccessTokenEvent.errorMessage == null) {
                // success!
                trace("Your access token value is: " + getAccessTokenEvent.accessToken);
            }
            else {
                // fail :(
            }
        }  // onGetAccessToken

    }
}
}
