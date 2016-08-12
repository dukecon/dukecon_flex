package nz.co.codec.flexorm.metamodel
{

    public class JoinColumns
    {
        import nz.co.codec.flexorm.Tags;

        public var _joinColumns:Array = [];

        public function JoinColumns()
        {
        }

        public function getJoinColumnsCount():uint
        {
            return _joinColumns.length;
        }

        public function fillJoinColumns(columnsArrayText:String, fkProperty:String):void
        {
            const JOIN_COLUMN_DELIMITER:String = ",";

            if (columnsArrayText != "" && columnsArrayText != null)
            {
                var reg1:RegExp = new RegExp(Tags.ATTR_JOIN_COLUMN_NAME + "\\s*=\\s*'(\\w+)'", "");

                // separate by JOIN_COLUMN_DELIMITER (",")
                var attrItems:Array = columnsArrayText.split(JOIN_COLUMN_DELIMITER);
                var attrItemLen:int = attrItems.length;

                for (var i:int = 0; i < attrItemLen; i++)
                {
                    var attrItem:String = attrItems[i];

                    // find out, if it matches the pattern joinColumnName = '..'
                    var matchingAttrItems:Array = attrItem.match(reg1);

                    if (matchingAttrItems == null)
                    {
                        continue; // ignore the ones not matching above pattern
                    }

                    // this is a trick: the content of (\\w+) from the pattern is stored in matchingAttrItem[1]
                    var matchingAttrItem:String = matchingAttrItems[matchingAttrItems.length - 1];
                    addJoinColumn(fkProperty, matchingAttrItem);
                }
            }
        }

        public function AddMissingJoinColumnsFromIdenties(identities:Array):void
        {
            for each (var identity:Identity in identities)
            {
                if (getColumnNameFromFkProperty(identity.fkProperty) == null)
                {
                    addJoinColumn(identity.fkProperty, identity.fkColumn);
                }
            }
        }

        public function getColumnNameFromFkProperty(fkProperty:String):String
        {
            var res:String = null;

            for each (var joinColumn:* in _joinColumns)
            {
                if (joinColumn.hasOwnProperty(fkProperty))
                {
                    res = joinColumn[fkProperty];
                    break;
                }
            }
            return res;
        }

        private function addJoinColumn(fkProperty:String, value:String):void
        {
            var joinColumn:Object = new Object();
            joinColumn[fkProperty] = value;
            _joinColumns.push(joinColumn);
        }
    }
}
