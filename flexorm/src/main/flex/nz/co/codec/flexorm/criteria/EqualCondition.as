package nz.co.codec.flexorm.criteria
{

    public class EqualCondition extends Condition
    {
        private var _str:*;

        public function EqualCondition(table:String, column:String, str:*)
        {
            super(table, column);
            _str = str;
        }

        override public function toString():String
        {
            var res:String = column + " = ";

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
