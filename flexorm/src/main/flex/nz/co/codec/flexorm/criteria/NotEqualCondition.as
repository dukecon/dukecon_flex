package nz.co.codec.flexorm.criteria
{

    public class NotEqualCondition extends Condition
    {
        private var _str:*;

        public function NotEqualCondition(table:String, column:String, str:*)
        {
            super(table, column);
            _str = str;
        }

        override public function toString():String
        {
            var res:String = column + " <> ";

            if (_str is String)
            {
                res += "'" + _str + "'";
            }
            else
            {
                res += _str;
            }
            return res;
        }
    }
}
