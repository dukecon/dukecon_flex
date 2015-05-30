////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package org.dukecon.utils
{

import spark.components.Group;
import spark.skins.mobile.ViewNavigatorSkin;

public class ViewNavigatorWithoutActionBarSkin extends ViewNavigatorSkin
{

    override protected function createChildren():void
    {
        contentGroup = new Group();
        contentGroup.id = "contentGroup";

        addChild(contentGroup);
    }

    override protected function measure():void
    {
        measuredMinWidth = 0;
        measuredMinHeight = 0;
        measuredWidth = 0;
        measuredHeight = 0;

        measuredWidth = contentGroup.getPreferredBoundsWidth();

        if (currentState == "portraitAndOverlay" || currentState == "landscapeAndOverlay")
        {
            measuredHeight = contentGroup.getPreferredBoundsHeight();
        }
        else
        {
            measuredHeight = contentGroup.getPreferredBoundsHeight();
        }
    }

    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        if (contentGroup.includeInLayout)
        {
            var contentGroupHeight:Number = unscaledHeight;
            var contentGroupPosition:Number = 0;

            contentGroup.setLayoutBoundsSize(unscaledWidth, contentGroupHeight);
            contentGroup.setLayoutBoundsPosition(0, contentGroupPosition);
        }
    }
}
}