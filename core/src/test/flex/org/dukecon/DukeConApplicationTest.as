/**
 * Created by christoferdutz on 07.05.15.
 */
package org.dukecon {
import mx.events.FlexEvent;

import org.flexunit.asserts.assertEquals;
import org.flexunit.async.Async;
import org.fluint.uiImpersonation.UIImpersonator;

import spark.components.Label;

public class DukeConApplicationTest {

    protected var appl:DukeConApplication;

    public function DukeConApplicationTest() {
    }

    [Before(async, ui)]
    public function setUp():void {
        appl = new DukeConApplication();
        Async.proceedOnEvent(this, appl, FlexEvent.CREATION_COMPLETE, 10000);
        UIImpersonator.addChild(appl);
    }

    [After(ui)]
    public function tearDown():void {
        UIImpersonator.removeChild(appl);
        appl = null;
    }

    [Test]
    public function testGreeting():void {
        var label:Label = appl.label;
        if(appl.currentLocale == "de_DE") {
            assertEquals(label.text, "Hallo Dukes!");
        } else {
            assertEquals(label.text, "Hi Dukes!");
        }
    }

}

}
