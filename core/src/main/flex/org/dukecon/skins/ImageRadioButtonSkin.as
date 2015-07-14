/**
 * Created by christoferdutz on 14.07.15.
 */
package org.dukecon.skins {
import spark.components.Image;
import spark.components.RadioButton;
import spark.skins.mobile.RadioButtonSkin;

public class ImageRadioButtonSkin extends RadioButtonSkin {

    [Embed(source="/rating-bad.png")]
    [Bindable]
    public var ratingBadImage:Class;

    [Embed(source="/rating-avg.png")]
    [Bindable]
    public var ratingAvgImage:Class;

    [Embed(source="/rating-good.png")]
    [Bindable]
    public var ratingGoodImage:Class;

    public var labelIcon:Image;

    public function ImageRadioButtonSkin() {
        super();
    }

    override protected function createChildren():void
    {
        super.createChildren();
        labelIcon = new Image();
        addChild(labelIcon);
    }

    override protected function commitProperties():void {
        super.commitProperties();
        switch(RadioButton(hostComponent).value) {
            case -1:
                labelIcon.source = ratingBadImage;
                break;
            case 0:
                labelIcon.source = ratingAvgImage;
                break;
            case 1:
                labelIcon.source = ratingGoodImage;
                break;
        }
    }

    override protected function measure():void
    {
        measuredMinWidth = 130;
        measuredMinHeight = 64;

        measuredWidth = 130;
        measuredHeight = 64;
    }

    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
        super.layoutContents(unscaledWidth, unscaledHeight);
        setElementSize(labelIcon, 64, 64);
        setElementPosition(labelIcon, 64, 0);
    }

}
}
