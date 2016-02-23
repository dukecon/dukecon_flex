/**
 * Created by christoferdutz on 23.02.16.
 */
package org.dukecon.utils {
import org.jboss.keycloak.flex.adapter.DefaultKeycloakAdapter;

public class DukeconKeycloakAdapter extends DefaultKeycloakAdapter {

    override public function parseResponse(responseString:String):XML {
        while(responseString.indexOf("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=5.0, minimum-scale=1.0\">") != -1) {
            responseString = responseString.replace("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=5.0, minimum-scale=1.0\">", "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=5.0, minimum-scale=1.0\"/>");
        }
        return super.parseResponse(responseString);
    }
    
    override public function getSocialProviders(doc:XML):Object {
        var providerList:XMLList = doc..ul.li.a;

        var providers:Object = {};
        for each(var provider:XML in providerList) {
            var name:String = provider.span;
            var url:String = provider.@href;
            providers[name] = url;
        }

        return providers;

    }

}
}
