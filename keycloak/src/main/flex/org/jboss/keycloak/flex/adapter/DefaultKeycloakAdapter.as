/**
 * Created by christoferdutz on 13.09.15.
 */
package org.jboss.keycloak.flex.adapter {
public class DefaultKeycloakAdapter implements KeycloakAdapter {

    public function parseResponse(responseString:String):XML {
        while(responseString.indexOf("&execution") != -1) {
            responseString = responseString.replace("&execution", "&amp;execution");
        }
        while(responseString.indexOf("autofocus ") != -1) {
            responseString = responseString.replace("autofocus ", "autofocus=\"\" ");
        }
        while(responseString.indexOf("checked>") != -1) {
            responseString = responseString.replace("checked>", "checked=\"\"/>");
        }
        while(responseString.indexOf("tabindex=\"3\"> Remember me") != -1) {
            responseString = responseString.replace("tabindex=\"3\"> Remember me", "tabindex=\"3\"/> Remember me");
        }
        while(responseString.indexOf("iefix&v=4") != -1) {
            responseString = responseString.replace("iefix&v=4", "iefix&amp;v=4");
        }

        return new XML(responseString);
    }

    public function getFeedbackMessage(doc:XML):String {
        namespace html = "http://www.w3.org/1999/xhtml";
        return doc..html::div.(hasOwnProperty('@id') && @id=='kc-feedback-wrapper').html::span[0];
    }

    public function getFormLoginUrlXPath(doc:XML):String {
        namespace html = "http://www.w3.org/1999/xhtml";
        var action:String = doc..html::form.(hasOwnProperty('@id') && @id=='kc-form-login').@action;
        return action;
    }

    public function getSocialProviders(doc:XML):Object {
        namespace html = "http://www.w3.org/1999/xhtml";
        var providerList:XMLList = doc..html::div.(hasOwnProperty('@id') && @id=='kc-social-providers')..html::a;

        var providers:Object = {};
        for each(var provider:XML in providerList) {
            var name:String = provider.html::span;
            var url:String = provider.@href;
            providers[name] = url;
        }

        return providers;
    }

}
}
