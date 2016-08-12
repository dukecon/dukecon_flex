package nz.co.codec.flexorm.criteria
{
    public class NullCondition extends Condition
    {
        private var _negated:Boolean;

        public function NullCondition(table:String, column:String, negated:Boolean = false)
        {
            super(table, column);
            _negated = negated;
        }

        override public function toString():String
        {
            return column + " IS " (_negated ? "NOT " : "") + "NULL";
        }
    }
}
