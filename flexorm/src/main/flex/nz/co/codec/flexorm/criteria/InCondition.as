package nz.co.codec.flexorm.criteria
{

    public class InCondition extends Condition
    {
        import nz.co.codec.flexorm.util.StringUtils;

        private var _arr:Array;
        private var _negated:Boolean;

        public function InCondition(table:String, column:String, arr:Array, negated:Boolean = false)
        {
            super(table, column);
            _arr = arr;
            _negated = negated;
        }

        override public function toString():String
        {
            var res:String = column + (_negated ? " NOT " : " ") + "IN (";
            _arr.forEach(constructSqlString);

            function constructSqlString(element:*, index:int, arr:Array):void
            {
                if (index > 0)
                {
                    res += ",";
                }

                if (element == null)
                {
                    res += "null";
                }
                else
                {
                    if (element is String)
                    {
                        res += "\"" + element.toString() + "\"";
                    }
                    else if (element is Date)
                    {
                        res += "strftime('%J','" + StringUtils.toSqlDate(element) + "')";
                    }
                    else
                    {
                        res += element.toString();
                    }
                }
            }

            res += ")";
            return res;
        }
    }
}
