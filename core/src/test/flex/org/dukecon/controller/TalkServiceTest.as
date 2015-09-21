/**
 * Created by christoferdutz on 18.09.15.
 */
package org.dukecon.controller {
import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertTrue;

public class TalkServiceTest {

    [Embed(source="/talks.json", mimeType="application/octet-stream")]
    private var talkDataResource:Class;

    public function TalkServiceTest() {
    }

    [Test]
    public function testJsonParsing():void {
        var talkData:String = (new talkDataResource()).toString();
        var result:* = JSON.parse(talkData);
        assertTrue(result is Array);
        var talks:Array = result as Array;
        assertEquals(talks.length, 102);
    }
}
}
