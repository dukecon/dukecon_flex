/**
 * Created by christoferdutz on 13.09.15.
 */
package org.jboss.keycloak.flex.adapter {
public interface KeycloakAdapter {

    function parseResponse(responseString:String):XML;

    function getFeedbackMessage(doc:XML):String;

    function getFormLoginUrlXPath(doc:XML):String;

    function getSocialProviders(doc:XML):Object;

}
}
