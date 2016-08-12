package nz.co.codec.flexorm.criteria
{
    public class LikeCondition extends Condition
    {
        private var _str:String;
        private var _negated:Boolean;

        public function LikeCondition(table:String, column:String, str:String, negated:Boolean = false)
        {
            super(table, column);
            _str = str;
            _negated = negated;
        }

        override public function toString():String
        {
            return column + (_negated ? " NOT " : " ") + "LIKE '%" + _str + "%'";
        }

    }
}
