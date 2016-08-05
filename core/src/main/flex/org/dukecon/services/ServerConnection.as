/**
 * Created by christoferdutz on 02.08.16.
 */
package org.dukecon.services {
import mx.messaging.ChannelSet;
import mx.messaging.MessageAgent;
import mx.messaging.channels.AMFChannel;
import mx.messaging.channels.SecureAMFChannel;

public class ServerConnection {

    private var _baseUrl:String;
    private var _connection:ChannelSet;

    public function ServerConnection() {
        _connection = new ChannelSet();
    }

    [Init]
    public function init():void {
        var shortPollingChannel:AMFChannel;
        if(_baseUrl.indexOf("https://") == 0) {
            shortPollingChannel = new SecureAMFChannel("shortPolling", _baseUrl + "/messagebroker/short-polling-amf");
        } else {
            shortPollingChannel = new AMFChannel("shortPolling", _baseUrl + "/messagebroker/short-polling-amf");
        }
        shortPollingChannel.pollingInterval = 30000;
        shortPollingChannel.piggybackingEnabled = true;
        _connection.addChannel(shortPollingChannel);
    }

    public function set baseUrl(value:String):void {
        _baseUrl = value;
    }

    public function get connection():ChannelSet {
        return _connection;
    }

}
}
