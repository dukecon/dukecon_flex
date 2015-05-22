/**
 * Created by christoferdutz on 22.05.15.
 */
package org.dukecon.utils {
import flash.display.DisplayObject;

import mx.core.UIComponent;

public class VectorImage extends UIComponent {
    public function VectorImage(source:Class = null) {
        if (source) {
            this.source = source;
        }
        super();
    }

    private var _source:Class;
    protected var sourceChanged:Boolean = true;


    public function get source():Class {
        return _source;
    }

    public function set source(value:Class):void {
        _source = value;
        sourceChanged = true;
        this.commitProperties();
    }

    protected var imageInstance:DisplayObject;


    override protected function createChildren():void {
        super.createChildren();

        // if the source has changed we want to create, or recreate, the image instance
        if (this.sourceChanged) {
            // if the instance has a value, then delete it
            if (this.imageInstance) {
                this.removeChild(this.imageInstance);
                this.imageInstance = null;
            }

            // if we have a source value; create the source
            if (this.source) {
                this.imageInstance = new source();
                this.addChild(this.imageInstance);
            }
            this.sourceChanged = false;

        }
    }

    /**
     * @private
     */
    override protected function commitProperties():void {
        super.commitProperties();

        if (this.sourceChanged) {
            // if the source changed re-created it; which is done in createChildren();
            this.createChildren();
        }
    }

    override protected function measure():void {
        if (imageInstance != null) {
            this.measuredWidth = imageInstance.width;
            this.measuredHeight = imageInstance.height;
            this.minWidth = 5;
            this.minHeight = 5;
        }
    }

    override public function setActualSize(width:Number, height:Number):void {
        this.width = width;
        this.height = height;
        ScaleImage(width, height);
    }

    /**
     * @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // size the element.
        // I don't remember why I Wrote the code to check for unscaledHeight and unscaledWidth being 0

        if (imageInstance != null) {

            //scale properly
            ScaleImage(unscaledWidth, unscaledHeight);
        }
    }

    protected function ScaleImage(width:Number, height:Number) {
        if (imageInstance != null) {
            var scale:Number = Math.min(width / imageInstance.width, height / imageInstance.height);

            var scaleWidth:Number = (int)(imageInstance.width * scale);
            var scaleHeight:Number = (int)(imageInstance.height * scale);

            imageInstance.width = scaleWidth;
            imageInstance.height = scaleHeight;

            imageInstance.x = (width - imageInstance.width) * .5;
            imageInstance.y = (height - imageInstance.height) * .5;
        }
    }
}
}
